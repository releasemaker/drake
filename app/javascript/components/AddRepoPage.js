import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'
import { Link } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faGithubAlt } from '@fortawesome/free-brands-svg-icons'
import { faCheck } from '@fortawesome/free-solid-svg-icons'
import { fetchFromBackend, UnexpectedBackendResponseError } from 'lib/backend-data'
import LoadIndicator from 'components/shared/LoadIndicator'
import AddRepoButton from 'components/AddRepoButton'

class AddRepoRow extends React.PureComponent {
  render() {
    return (
      <tr>
        <td className='name'>
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
        <td className='add-button'>
          {this.props.isEnabled
            ? (
              <FontAwesomeIcon
                icon={faCheck}
                size='sm'
                aria-label="Enabled"
              />
            ) : (
              <AddRepoButton
                path={this.props.path}
                onEnabled={this.props.onRepoEnabled}
              />
            )
          }
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

    // Restore the cache only if the user navigated back to this page.
    const availableRepos = this.props.history.action == 'POP' &&
      this.props.location.state && this.props.location.state.availableRepos

    // Get whatever state we want to restore from the location state.
    // This will allow seamless navigation back to this page, since we set the state when we finished fetching.
    this.state = {
      availableRepos,
      searchTerm: query.get('q') || '',
      isFetchingRepos: false,
      totalPageCount: null,
      fetchedPageCount: 0,
    }
  }

  componentDidMount() {
    if (!this.state.availableRepos) {
      this.fetchRepos()
    }
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (nextState.availableRepos !== this.state.availableRepos && !nextState.isFetchingRepos) {
      // Store the available repos in our location state so it will be restored when navigating back.
      this.props.history.replace({ ...this.props.location, state: {
        availableRepos: this.state.availableRepos,
      } })
    }

    return true
  }

  fetchRepos() {
    this.setState({
      isFetchingRepos: true,
    })
    this.fetchNextPageOfRepos()
  }

  fetchNextPageOfRepos() {
    const nextPageNum = this.state.fetchedPageCount + 1
    return fetchFromBackend(`/api/availableRepos?page=${nextPageNum}`, {
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
          }, () => {
            if (morePagesToFetch) {
              this.fetchNextPageOfRepos()
            }
          })
        }).catch((error) => {
          this.setState(() => { throw error })
        })
      } else {
        this.setState(() => { throw new UnexpectedBackendResponseError(response.status) })
      }
    }).catch((error) => {
      this.setState(() => { throw error })
    })
  }

  handleRepoEnabled = (repo_path, updated_repo) => {
    const availableRepos = this.state.availableRepos.map((repo) => repo.path === repo_path ? updated_repo : repo)
    this.setState({ availableRepos })
  }

  handleSearchTermChanged = (event) => {
    let search

    const searchTerm = event.target.value
    this.setState({ searchTerm })

    const query = new URLSearchParams(this.props.location.search)
    if (searchTerm !== '') {
      query.set('q', searchTerm)
      search = query.toString()
    } else {
      search = null
    }

    this.props.history.push({ ...this.props.location, search })
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
        {this.state.isFetchingRepos && <LoadIndicator>Loading more</LoadIndicator>}
      </React.Fragment>
    )
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
