import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'

class ErrorPage extends React.Component {
  showErrorReportDialog = () => {
    Sentry.showReportDialog({
      eventId: this.props.errorEventId,
      title: "Give the developers your feedback.",
      subtitle: "They promise to make it better.",
      subtitle2: "Just tell them how.",
    })
  }

  reloadPage = () => {
    window.location.reload()
  }

  goBack = () => {
    window.history.go(-1)
  }

  render () {
    return (
      <div id='error-page'>
        <div className='messaging'>
          <h1>Something Went Wrong</h1>
          <p>Iʼm sorry to have to tell you this, something broke on this page.</p>
          <p>
            Iʼm notifying the developers.
            If you want to give them more information about how you arrived at this error
            , please <a onClick={this.showErrorReportDialog}>report feedback</a>
            . They appreciate your help and patience!
          </p>
          <p>
            <a onClick={this.reloadPage}>Reload the page to try again</a>
          </p>
          <p>
            <a onClick={this.goBack}>Go back</a> to the previous page
          </p>
          <p>
            <a href='/'>Release Maker</a>
          </p>
        </div>
      </div>
    )
  }
}

ErrorPage.propTypes = {
  error: PropTypes.any,
  errorEventId: PropTypes.string,
}

export default ErrorPage
