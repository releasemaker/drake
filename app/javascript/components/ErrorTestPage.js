import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'
import { Button, Colors, Sizes } from 'react-foundation'
import { Link } from 'react-router-dom'
import LoadIndicator from 'components/shared/LoadIndicator'
import { fetchFromBackend, UnexpectedBackendResponseError } from 'lib/backend-data'

class ErrorTestPage extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isFetchingServerError: false,
      isFetchingJsonError: false,
      gimmeRenderError: false,
    }
  }

  gimmeServerError = () => {
    this.setState({
      isFetchingServerError: true,
    })

    return fetchFromBackend(`/api/gimme/error`, {
      method: 'GET',
    }).then((response) => {
      if (response.ok) {
        this.setState({
          isFetchingServerError: false,
        })
      } else {
        this.setState(() => { throw new UnexpectedBackendResponseError(response.status) })
      }
    }).catch((error) => {
      this.setState(() => { throw error })
    })
  }

  gimmeJsonError = () => {
    this.setState({
      isFetchingJsonError: true,
    })

    return fetchFromBackend(`/api/gimme/bad-json`, {
      method: 'GET',
    }).then((response) => {
      if (response.ok) {
        response.json().then((json) => {
          this.setState({
            isFetchingJsonError: false,
          })
        }).catch((error) => {
          this.setState(() => { throw error })
        })
      }
    }).catch((error) => {
    })
  }

  gimmeRenderError = () => {
    this.setState({ gimmeRenderError: true })
  }

  gimmeNotFound = () => {
    this.props.onContentNotFound(this.props.location)
  }

  render () {
    return (
      <React.Fragment>
        <h1>Gimme Errors</h1>
        <h2>Backend Server Error</h2>
        <p>Make a fetch to the backend that results in a 500 status.</p>
        {this.state.isFetchingServerError && <LoadIndicator>Fetching Server Error</LoadIndicator>}
        {!this.state.isFetchingServerError && <p><Button onClick={this.gimmeServerError}>Gimme</Button></p>}
        <h2>Backend Server JSON Response Error</h2>
        <p>Make a fetch to the backend that gives back unparseable JSON.</p>
        {this.state.isFetchingJsonError && <LoadIndicator>Fetching Bad JSON Response</LoadIndicator>}
        {!this.state.isFetchingJsonError && <p><Button onClick={this.gimmeJsonError}>Gimme</Button></p>}
        <h2>Rendering Error</h2>
        <p>Cause rendering to raise an exception.</p>
        {this.state.gimmeRenderError && I_BROKE_RENDERING}
        <p><Button onClick={this.gimmeRenderError}>Gimme</Button></p>
        <h2>Content Not Found</h2>
        <p>When a component requires data to be loaded from the backend, but the backend reports 404.</p>
        <p><Button onClick={this.gimmeNotFound}>Gimme</Button></p>
        <h2>Plain Not Found Page</h2>
        <p>Go to a page that doesn't exist, so you can see what that looks like.</p>
        <p><a href="/a-page-that-does-not-exist">Gimme</a></p>
      </React.Fragment>
    )
  }
}

ErrorTestPage.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
  onContentNotFound: PropTypes.func.isRequired,
}

export default ErrorTestPage
