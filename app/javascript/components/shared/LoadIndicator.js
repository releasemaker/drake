import React from "react"
import PropTypes from "prop-types"
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCompactDisc } from '@fortawesome/free-solid-svg-icons'

class LoadIndicator extends React.PureComponent {
  render() {
    return (
      <div className='loading-indicator'>
        <div className='inner'>
          <FontAwesomeIcon icon={faCompactDisc} aria-hidden size='lg' pulse />
          <span className='message'>{this.props.children || "Loading more"}…</span>
        </div>
      </div>
    )
  }
}

LoadIndicator.propTypes = {
  children: PropTypes.node,
}

export default LoadIndicator
