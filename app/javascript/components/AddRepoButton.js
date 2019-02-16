import React from 'react'
import PropTypes from 'prop-types'
import * as Sentry from '@sentry/browser'
import { Button, Switch, Colors, Sizes } from 'react-foundation'
import { Link } from 'react-router-dom'
import { fetchFromBackend, UnexpectedBackendResponseError } from 'lib/backend-data'
import SyncIndicator from 'components/shared/SyncIndicator'

class AddRepoButton extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isMakingEnableRequest: false,
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

    return fetchFromBackend(`/api/repos${this.props.path}`, {
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
          })
        })
      } else {
        throw new UnexpectedBackendResponseError(response.status)
      }
    })
  }

  render() {
      return (
        <React.Fragment>
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
