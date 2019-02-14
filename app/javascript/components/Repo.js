import React from 'react'
import PropTypes from 'prop-types'
import * as Sentry from '@sentry/browser'
import { Button, Colors, Sizes } from 'react-foundation'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import fetch from 'lib/fetch'

class Repo extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isEnabled: props.isEnabled,
      isMakingEnableRequest: false,
      wasServerError: false,
      url: props.url,
    }
  }

  handleEnable = () => {
    this.setState({
      isMakingEnableRequest: true,
    })

    return fetch("/repos.json", {
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
        <a href={this.state.url}>
          Enabled
        </a>
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

Repo.propTypes = {
  isEnabled: PropTypes.bool.isRequired,
  repoType: PropTypes.string.isRequired,
  providerUid: PropTypes.string.isRequired,
  name: PropTypes.string,
  url: PropTypes.string,
}

export default Repo
