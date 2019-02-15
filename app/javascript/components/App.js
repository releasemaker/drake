import React from 'react'
import { BrowserRouter as Router, Route, Link, Switch } from 'react-router-dom'
import AddRepo from 'components/AddRepo'

class App extends React.Component {
  render() {
    return (
      <div>
        <Router>
          <Route path="/repos/new" component={AddRepo} />
        </Router>
      </div>
    )
  }
}

export default App
