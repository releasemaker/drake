import React from 'react'
import PropTypes from 'prop-types'
import * as Sentry from '@sentry/browser'
import { Button, Switch, Colors, Sizes } from 'react-foundation'
import { Link } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCheck } from '@fortawesome/free-solid-svg-icons'
import fetch from 'lib/fetch'

class AddRepoButton extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isMakingEnableRequest: false,
      wasServerError: false,
    }
  }

  handleClickedSwitch = () => {
    if (!this.state.isMakingEnableRequest) {
      if (!this.props.isEnabled) {
        this.enableRepo()
      } else {
        
      }
    }
  }

  enableRepo() {
    this.setState({
      isMakingEnableRequest: true,
    })

    return fetch("/api/repos", {
      method: 'POST',
      body: JSON.stringify({
        repo: {
          type: this.props.repoType,
          provider_uid_or_url: this.props.providerUid,
          name: this.props.name,
        },
      }),
    }).then((response) => {
      if (response.ok) {
        response.json().then((json) => {
          this.props.onEnabled(this.props.path, json.repo)
          this.setState({
            isMakingEnableRequest: false,
            wasServerError: false,
          })
        }).catch((error) => {
          this.setState({
            isMakingEnableRequest: false,
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
        isMakingEnableRequest: false,
        wasServerError: true,
      })
      Sentry.captureException(error)
      console.log('Failure enabling repo')
      console.log(error)
    })
  }

  render() {
      return (
        <React.Fragment>
          {this.state.wasServerError && (
            <span>Failed, please try again</span>
          )}
          {this.props.isEnabled
            ? (
              <FontAwesomeIcon
                icon={faCheck}
                size='sm'
                aria-label="Enabled"
              />
            ) : (
              <Switch
                size={Sizes.SMALL}
                onClick={this.handleClickedSwitch}
              />
            )
          }
          {this.state.isMakingEnableRequest && (
              <span>Enabling...</span>
          )}
        </React.Fragment>
      )
    // }
  }
}

AddRepoButton.propTypes = {
  isEnabled: PropTypes.bool.isRequired,
  repoType: PropTypes.string.isRequired,
  providerUid: PropTypes.string.isRequired,
  name: PropTypes.string,
  path: PropTypes.string,
  onEnabled: PropTypes.func,
}

export default AddRepoButton
