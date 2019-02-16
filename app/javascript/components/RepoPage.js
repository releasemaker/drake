import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'
import RepoSettings from 'components/RepoSettings'
import LoadIndicator from 'components/shared/LoadIndicator'

class RepoPage extends React.Component {
  constructor(props) {
    super(props)

    // Restore the cache only if the user navigated back to this page.
    const repo = this.props.history.action == 'POP' &&
      this.props.location.state && this.props.location.state.repo

    this.state = {
      repo,
      isFetchingRepo: false,
      wasServerError: false,
      repoNotFound: false,
    }
  }

  componentDidMount() {
    if (!this.state.repo) {
      this.fetchRepo()
    }
  }

  shouldComponentUpdate(nextProps, nextState) {
    // If the route changes while this component is already opened, it won't get remounted.
    // So look for the route data to change and load the new repo.
    if (nextProps.match.url !== this.props.match.url) {
      this.fetchRepo()
    }

    if (nextState.repo != this.state.repo && !nextState.isFetchingRepo) {
      // Store the repo in our location state so it will be restored when navigating back.
      if (this.state.repo && this.state.repo.path !== nextState.repo.path) {
        // If the fetched repo has a different path, it's likely been renamed, so we want to redirect to the new name
        // seamlessly.
        window.history.replace({ pathname: newState.repo.path, state: {
          repo: this.state.repo,
        } })
      } else {
        this.props.history.replace({ ...this.props.location, state: {
          repo: this.state.repo,
        } })
      }
    }

    return true
  }

  handleRepoUpdated = (path, repo) => {
    this.setState({ repo })
  }

  fetchRepo() {
    this.setState({
      isFetchingRepo: true,
      repo: null,
    })

    const repoPath = `/${this.props.match.params.type}/${this.props.match.params.name}`
    return fetch(`/api/repos${repoPath}`, {
      method: 'GET',
    }).then((response) => {
      if (response.ok) {
        response.json().then((json) => {
          this.setState({
            repo: json.repo,
            isFetchingRepo: false,
            wasServerError: false,
          })
        })
      } else if (response.status == 404) {
        this.props.onContentNotFound(this.props.location)
      } else {
        throw new Error("Request failed")
      }
    })
  }

  render () {
    return (
      <React.Fragment>
        <h1>{this.props.name}</h1>
        {this.state.isFetchingRepo && <LoadIndicator>Loading</LoadIndicator>}
        {this.state.repo && (
          <RepoSettings
            isEnabled={this.state.repo.isEnabled}
            name={this.state.repo.name}
            repoType={this.state.repo.repoType}
            ownerName={this.state.repo.ownerName}
            repoName={this.state.repo.repoName}
            path={this.state.repo.path}
            providerUid={this.state.repo.providerUid}
            onUpdated={this.handleRepoUpdated}
          />
        )}
      </React.Fragment>
    );
  }
}

RepoPage.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      type: PropTypes.oneOf(['gh']).isRequired,
      name: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
  onContentNotFound: PropTypes.func.isRequired,
}

export default RepoPage
