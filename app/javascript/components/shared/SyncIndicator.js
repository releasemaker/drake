import React from "react"
import PropTypes from "prop-types"
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faSync } from '@fortawesome/free-solid-svg-icons'

class LoadingIndicator extends React.PureComponent {
  render() {
    return (
      <FontAwesomeIcon icon={faSync} aria-label='One moment…' size={this.props.size} pulse />
    )
  }
}

LoadingIndicator.propTypes = {
  size: PropTypes.string,
}

LoadingIndicator.defaultProps = {
  size: 'lg',
}

export default LoadingIndicator
