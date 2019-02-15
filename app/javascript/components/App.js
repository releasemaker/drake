import React from 'react'
import { BrowserRouter as Router, Route, Link, Switch } from 'react-router-dom'
import AddRepoPage from 'components/AddRepoPage'
import RepoPage from 'components/RepoPage'
import RepoIndexPage from 'components/RepoIndexPage'

class App extends React.Component {
  render() {
    return (
      <Router>
        <React.Fragment>
          <div className='top-bar'>
            <div className='top-bar-left'>
              <ul className='dropdown menu' data-dropdown-menu={true}>
                <li className='menu-text'>Release Maker</li>
                <li><Link to='/repos'>Projects</Link></li>
              </ul>
            </div>
            <div className='top-bar-right'>
              <ul className='menu'>
                <li>
                  <a href='/sign-out'>Sign Out</a>
                </li>
              </ul>
            </div>
          </div>
          <div className='expanded.row'>
            <div className='medium-12 large-12 columns'>
              <Route exact path="/repos" component={RepoIndexPage} />
              <Route exact path="/repos/new" component={AddRepoPage} />
              <Route path="/:type(gh)/:name*" component={RepoPage} />
            </div>
          </div>
        </React.Fragment>
      </Router>
    )
  }
}

export default App
