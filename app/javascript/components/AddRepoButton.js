import React from 'react'
import PropTypes from 'prop-types'
import * as Sentry from '@sentry/browser'
import { Button, Switch, Colors, Sizes } from 'react-foundation'
import { Link } from 'react-router-dom'
import fetch from 'lib/fetch'
import SyncIndicator from 'components/shared/SyncIndicator'

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
      this.enableRepo()
    }
  }

  enableRepo() {
    this.setState({
      isMakingEnableRequest: true,
    })

    return fetch(`/api/repos${this.props.path}`, {
      method: 'POST',
      body: JSON.stringify({
        repo: {
          isEnabled: true,
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
          <Switch
            size={Sizes.SMALL}
            onClick={this.handleClickedSwitch}
          />
          {this.state.isMakingEnableRequest && <SyncIndicator/>}
        </React.Fragment>
      )
    // }
  }
}

AddRepoButton.propTypes = {
  path: PropTypes.string,
  onEnabled: PropTypes.func,
}

export default AddRepoButton
