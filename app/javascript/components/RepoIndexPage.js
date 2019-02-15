import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'
import { Link } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faGithubAlt } from '@fortawesome/free-brands-svg-icons'

class RepoIndexRow extends React.PureComponent {
  render() {
    return (
      <tr data-provider-uid={this.props.providerUid}>
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

    this.state = {
      repos: [],
      searchTerm: '',
      isFetchingRepos: false,
      wasServerError: false,
      totalPageCount: null,
      fetchedPageCount: 0,
    }
  }

  componentDidMount() {
    this.fetchRepos()
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
            repos: [...this.state.repos, ...json.repos],
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
  }

  reposToShow() {
    if (this.state.searchTerm !== '') {
      const searchTerm = this.state.searchTerm.toLowerCase()
      return this.state.repos.filter((repo) => repo.name.toLowerCase().includes(searchTerm))
    } else {
      return this.state.repos
    }
  }

  render () {
    return (
      <React.Fragment>
        <h1>Projects</h1>
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
        {this.state.isFetchingRepos && (
          <p>Fetching more…</p>
        )}
      </React.Fragment>
    );
  }
}

export default RepoIndexPage
