import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'
import { Button, Switch, Colors, Sizes } from 'react-foundation'
import AddRepoButton from 'components/AddRepoButton'
import SyncIndicator from 'components/shared/SyncIndicator'
import { fetchFromBackend, UnexpectedBackendResponseError } from 'lib/backend-data'

class RepoSettings extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isMakingDisableRequest: false,
    }
  }

  handleDisableClicked = () => {
    this.setState({
      isMakingDisableRequest: true,
    })

    return fetchFromBackend(`/api/repos${this.props.path}`, {
      method: 'PATCH',
      body: JSON.stringify({
        repo: {
          isEnabled: false,
        },
      }),
    }).then((response) => {
      if (response.ok) {
        response.json().then((json) => {
          this.props.onUpdated && this.props.onUpdated(this.props.path, json.repo)
          this.setState({
            isMakingDisableRequest: false,
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

  handleEnabled = (path, repo_info) => {
    this.props.onUpdated && this.props.onUpdated(path, repo_info)
  }

  render () {
    return (
      <React.Fragment>
        {this.props.isEnabled && (
          this.state.isMakingDisableRequest
          ? (
            <SyncIndicator />
          ) : (
            <Button
              onClick={this.handleDisableClicked}
              colors={Colors.ALERT}
            >
              Disable this repository
            </Button>
          )
        )}
        {!this.props.isEnabled && (
          <AddRepoButton
            isEnabled={this.props.isEnabled}
            name={this.props.name}
            repoType={this.props.repoType}
            providerUid={this.props.providerUid}
            path={this.props.path}
            onEnabled={this.handleEnabled}
          />
        )}
      </React.Fragment>
    )
  }
}

RepoSettings.propTypes = {
  isEnabled: PropTypes.bool.isRequired,
  name: PropTypes.string.isRequired,
  repoType: PropTypes.oneOf(['gh']).isRequired,
  ownerName: PropTypes.string.isRequired,
  repoName: PropTypes.string.isRequired,
  path: PropTypes.string.isRequired,
  providerUid: PropTypes.string.isRequired,
  onUpdated: PropTypes.func,
}

export default RepoSettings
