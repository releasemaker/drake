import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'
import { Link } from 'react-router-dom'
import { Button, Colors, Sizes } from 'react-foundation'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faGithubAlt } from '@fortawesome/free-brands-svg-icons'
import { faPlusCircle, faCompactDisc } from '@fortawesome/free-solid-svg-icons'
import LoadIndicator from 'components/shared/LoadIndicator'

class RepoIndexRow extends React.PureComponent {
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
          <Link to={this.props.path}>{this.props.name}</Link>
        </td>
      </tr>
    )
  }
}

RepoIndexRow.propTypes = {
  isEnabled: PropTypes.bool.isRequired,
  repoType: PropTypes.string.isRequired,
  providerUid: PropTypes.string.isRequired,
  name: PropTypes.string,
  path: PropTypes.string,
}

class RepoIndexPage extends React.Component {
  constructor(props) {
    super(props)

    const query = new URLSearchParams(props.location.search)

    // Restore the cache only if the user navigated back to this page.
    const repos = this.props.history.action == 'POP' &&
      this.props.location.state && this.props.location.state.repos

    // Get whatever state we want to restore from the location state.
    // This will allow seamless navigation back to this page, since we set the state when we finished fetching.
    this.state = {
      repos,
      searchTerm: query.get('q') || '',
      isFetchingRepos: false,
      wasServerError: false,
      totalPageCount: null,
      fetchedPageCount: 0,
    }
  }

  componentDidMount() {
    if (!this.state.repos) {
      this.fetchRepos()
    }
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (nextState.repos !== this.state.repos && !nextState.isFetchingRepos) {
      // Store the available repos in our location state so it will be restored when navigating back.
      this.props.history.replace({ ...this.props.location, state: {
        repos: this.state.repos,
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
    return fetch(`/api/repos?page=${nextPageNum}`, {
      method: 'GET',
    }).then((response) => {
      if (response.ok) {
        response.json().then((json) => {
          const morePagesToFetch = json.pagination.currentPageNum < json.pagination.totalPages
          this.setState({
            repos: [...this.state.repos || [], ...json.repos],
            totalPageCount: json.pagination.totalPages,
            fetchedPageCount: json.pagination.currentPageNum,
            isFetchingRepos: morePagesToFetch,
            wasServerError: false,
          }, () => {
            if (morePagesToFetch) {
              this.fetchNextPageOfRepos()
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
      return this.state.repos.filter((repo) => repo.name.toLowerCase().includes(searchTerm) && repo.isEnabled)
    } else {
      return this.state.repos.filter((repo) => repo.isEnabled)
    }
  }

  render () {
    return (
      <React.Fragment>
        <h1>Projects</h1>
        <div>
          <Link to='/repos/new'>
            <Button
              color={Colors.SUCCESS}
            >
              <FontAwesomeIcon
                icon={faPlusCircle}
                size='sm'
              />
              {' '}
              Add Repository
            </Button>
          </Link>
        </div>
        <div>
          <input
            type='text'
            value={this.state.searchTerm}
            onChange={this.handleSearchTermChanged}
            placeholder='Filter'
          />
        </div>
        {this.state.repos && (
          <table className='repos'>
            <tbody>
              {this.reposToShow().map((repo) => (
                <RepoIndexRow
                  key={repo.path}
                  isEnabled={repo.isEnabled}
                  name={repo.name}
                  repoType={repo.repoType}
                  providerUid={repo.providerUid}
                  path={repo.path}
                />
              ))}
            </tbody>
          </table>
        )}
        {this.state.isFetchingRepos && <LoadIndicator>Loading more</LoadIndicator>}
      </React.Fragment>
    );
  }
}

RepoIndexPage.propTypes = {
  history: PropTypes.shape({
    push: PropTypes.func.isRequired,
    replace: PropTypes.func.isRequired,
  }).isRequired,
  location: PropTypes.shape({
    state: PropTypes.shape({
      repos: PropTypes.array,
    }),
  }).isRequired,
}

export default RepoIndexPage
