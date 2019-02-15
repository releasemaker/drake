import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faGithubAlt } from '@fortawesome/free-brands-svg-icons'
import { Link } from 'react-router-dom'
import AddRepoButton from 'components/AddRepoButton'

class AddRepoRow extends React.PureComponent {
  render() {
    return (
      <tr data-provider-uid={this.props.providerUid}>
        <td>
          <FontAwesomeIcon
            icon={faGithubAlt}
            size='sm'
            aria-label="GitHub"
          />
          {' '}
          {this.props.isEnabled
            ? (
              <Link to={this.props.path}>
                {this.props.name}
              </Link>
            ) : this.props.name}
        </td>
        <td>
          <AddRepoButton
            isEnabled={this.props.isEnabled}
            name={this.props.name}
            repoType={this.props.repoType}
            providerUid={this.props.providerUid}
            path={this.props.path}
            onEnabled={this.props.onRepoEnabled}
          />
        </td>
      </tr>
    )
  }
}

AddRepoRow.propTypes = {
  isEnabled: PropTypes.bool.isRequired,
  repoType: PropTypes.string.isRequired,
  providerUid: PropTypes.string.isRequired,
  name: PropTypes.string,
  path: PropTypes.string,
  onRepoEnabled: PropTypes.func,
}

class AddRepoPage extends React.Component {
  constructor(props) {
    super(props)

    const query = new URLSearchParams(props.location.search)

    // Get whatever state we want to restore from the location state.
    // This will allow seamless navigation back to this page, since we set the state when we finished fetching.
    this.state = {
      availableRepos: this.props.location.state && this.props.location.state.availableRepos,
      searchTerm: query.get('q') || '',
      isFetchingRepos: false,
      wasServerError: false,
      totalPageCount: null,
      fetchedPageCount: 0,
    }
  }

  componentDidMount() {
    if (!this.state.availableRepos) {
      this.fetchRepos()
    }
  }

  fetchRepos() {
    this.setState({
      isFetchingRepos: true,
    })
    this.fetchNextPageOfRepos()
  }

  fetchNextPageOfRepos() {
    const nextPageNum = this.state.fetchedPageCount + 1
    return fetch(`/api/availableRepos?page=${nextPageNum}`, {
      method: 'GET',
    }).then((response) => {
      if (response.ok) {
        response.json().then((json) => {
          const morePagesToFetch = json.pagination.currentPageNum < json.pagination.totalPages
          this.setState({
            availableRepos: [...this.state.availableRepos || [], ...json.availableRepos],
            totalPageCount: json.pagination.totalPages,
            fetchedPageCount: json.pagination.currentPageNum,
            isFetchingRepos: morePagesToFetch,
            wasServerError: false,
          }, () => {
            if (morePagesToFetch) {
              this.fetchNextPageOfRepos()
            } else {
              // Store the fetched content in our location state so it will be restored when navigating back.
              this.props.history.replace({ ...this.props.location, state: {
                availableRepos: this.state.availableRepos,
              } })
            }
          })
        }).catch((error) => {
          this.setState({
            isFetchingRepos: false,
            wasServerError: true,
          })
          Sentry.captureException(error)
          console.log('Failure enabling repo while parsing response')
          console.log(error)
        })
      } else {
        throw response
      }
    }).catch((error) => {
      this.setState({
        isFetchingRepos: false,
        wasServerError: true,
      })
      Sentry.captureException(error)
      console.log('Failure enabling repo')
      console.log(error)
    })
  }

  handleRepoEnabled = (repo_path, updated_repo) => {
    const availableRepos = this.state.availableRepos.map((repo) => repo.path === repo_path ? updated_repo : repo)
    this.setState({ availableRepos })
  }

  handleSearchTermChanged = (event) => {
    const searchTerm = event.target.value
    this.setState({ searchTerm })

    const query = new URLSearchParams(this.props.location.search)
    query.set('q', searchTerm)
    this.props.history.push({ ...this.props.location, search: query.toString() })
  }

  reposToShow() {
    if (this.state.searchTerm !== '') {
      const searchTerm = this.state.searchTerm.toLowerCase()
      return this.state.availableRepos.filter((repo) => repo.name.toLowerCase().includes(searchTerm))
    } else {
      return this.state.availableRepos.filter((repo) => !repo.isEnabled)
    }
  }

  render () {
    return (
      <React.Fragment>
        <h1>Add Repo</h1>
        <div>
          <input
            type='text'
            value={this.state.searchTerm}
            onChange={this.handleSearchTermChanged}
            placeholder='Filter'
          />
        </div>
        {this.state.availableRepos && (
          <table className='repos'>
            <tbody>
              {this.reposToShow().map((repo) => (
                <AddRepoRow
                  key={repo.path}
                  isEnabled={repo.isEnabled}
                  name={repo.name}
                  repoType={repo.repoType}
                  providerUid={repo.providerUid}
                  path={repo.path}
                  onRepoEnabled={this.handleRepoEnabled}
                />
              ))}
            </tbody>
          </table>
        )}
        {this.state.isFetchingRepos && (
          <p>Fetching more…</p>
        )}
      </React.Fragment>
    );
  }
}

AddRepoPage.propTypes = {
  history: PropTypes.shape({
    push: PropTypes.func.isRequired,
    replace: PropTypes.func.isRequired,
  }).isRequired,
  location: PropTypes.shape({
    state: PropTypes.shape({
      availableRepos: PropTypes.array,
    }),
  }).isRequired,
}

export default AddRepoPage
