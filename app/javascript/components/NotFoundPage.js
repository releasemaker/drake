import React from "react"
import PropTypes from "prop-types"
import * as Sentry from '@sentry/browser'

class NotFoundPage extends React.Component {
  showErrorReportDialog = () => {
    Sentry.showReportDialog({
      title: "Tell us how weʼre wrong.",
      subtitle: "We appreciate it. Really!",
      subtitle2: "Tell us how we can make it better.",
      labelSubmit: "Send",
    })
  }

  goBack = () => {
    window.history.go(-1)
  }

  render () {
    return (
      <div id='not-found-page'>
        <div className='messaging'>
          <h1>Not Found</h1>
          <p>
            Youʼve landed on a URL that does not have any content on
            the <a href='/'>Release Maker</a> site.
          </p>
          <p>
            If you feel there should be content at this URL
            , please <a onClick={this.showErrorReportDialog}>report feedback to the developers</a>
            . They appreciate your help and patience!
          </p>
          <p>
            <a onClick={this.goBack}>Go back</a> to the previous page
          </p>
        </div>
      </div>
    )
  }
}

NotFoundPage.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string.isRequired,
  }).isRequired,
}

export default NotFoundPage
