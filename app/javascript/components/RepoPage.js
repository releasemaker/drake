import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'
import RepoSettings from 'components/RepoSettings'

class RepoPage extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      repo: null,
      isFetchingRepo: false,
      wasServerError: false,
    }
  }

  componentDidMount() {
    this.fetchRepo()
  }

  shouldComponentUpdate(nextProps, nextState) {
    // If the route changes while this component is already opened, it won't get remounted.
    // So look for the route data to change and load the new repo.
    if (nextProps.match !== this.props.match) {
      this.fetchRepo()
    }

    // If the fetched repo has a different path, it's likely been renamed, so we want to redirect to the new name
    // seamlessly.
    if (this.state.repo && this.state.repo.path !== nextState.repo.path) {
      window.history.replace(nextState.repo.path)
    }

    return true
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
        }).catch((error) => {
          this.setState({
            isFetchingRepo: false,
            wasServerError: true,
          })
          Sentry.captureException(error)
          console.log('Failure fetching repo while parsing response')
          console.log(error)
        })
      } else {
        throw response
      }
    }).catch((error) => {
      this.setState({
        isFetchingRepo: false,
        wasServerError: true,
      })
      Sentry.captureException(error)
      console.log('Failure fetching repo')
      console.log(error)
    })
  }

  render () {
    return (
      <React.Fragment>
        {this.state.isFetchingRepo && (
          <p>Loading…</p>
        )}
        {this.state.repo && (
          <RepoSettings
            isEnabled={this.state.repo.isEnabled}
            name={this.state.repo.name}
            repoType={this.state.repo.repoType}
            ownerName={this.state.repo.ownerName}
            repoName={this.state.repo.repoName}
            path={this.state.repo.path}
          />
        )}
      </React.Fragment>
    );
  }
}

RepoPage.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      type: PropTypes.oneOf(['gh']).isRequired,
      name: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
}

export default RepoPage
