import React from 'react'
import PropTypes from 'prop-types'
import * as Sentry from '@sentry/browser'
import { Button, Colors, Sizes } from 'react-foundation'
import { Link } from 'react-router-dom'
import fetch from 'lib/fetch'

class AddRepoButton extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isEnabled: props.isEnabled,
      isMakingEnableRequest: false,
      wasServerError: false,
    }
  }

  handleEnable = () => {
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
          this.setState({
            isEnabled: json.enabled,
            url: json.url,
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
    if (this.state.isEnabled) {
      return (
        <Link to={this.props.path}>
          Enabled
        </Link>
      )
    } else if (this.state.isMakingEnableRequest) {
      return (
        <div>Enabling...</div>
      )
    } else {
      // TODO: turn this into a Switch control
      return (
        <div>
          {this.state.wasServerError && (
            <p>Failed, please try again</p>
          )}
          <Button
            className='add-repo'
            size={Sizes.SMALL}
            color={Colors.SUCCESS}
            onClick={this.handleEnable}
          >
            Enable
          </Button>
        </div>
      )
    }
  }
}

AddRepoButton.propTypes = {
  isEnabled: PropTypes.bool.isRequired,
  repoType: PropTypes.string.isRequired,
  providerUid: PropTypes.string.isRequired,
  name: PropTypes.string,
  path: PropTypes.string,
}

export default AddRepoButton
