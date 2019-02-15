import React from "react"
import PropTypes from "prop-types"

class RepoSettings extends React.Component {
  render () {
    return (
      <React.Fragment>
        <h1>{this.props.name}</h1>
        <p>Enabled: {this.props.isEnabled}</p>
      </React.Fragment>
    );
  }
}

RepoSettings.propTypes = {
  isEnabled: PropTypes.bool.isRequired,
  name: PropTypes.string.isRequired,
  repoType: PropTypes.oneOf(['gh']).isRequired,
  ownerName: PropTypes.string.isRequired,
  repoName: PropTypes.string.isRequired,
  path: PropTypes.string.isRequired,
}

export default RepoSettings
