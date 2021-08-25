import React from 'react'
import * as Sentry from '@sentry/browser'
import { BrowserRouter as Router, Route, Link, Switch } from 'react-router-dom'
import AddRepoPage from '~pages/AddRepo'
import RepoPage from '~pages/Repo'
import RepoIndexPage from '~pages/RepoIndex'
import ErrorTestPage from '~pages/ErrorTest'
import ErrorPage from '~pages/Error'
import NotFoundPage from '~pages/NotFound'

class App extends React.Component {
  constructor(props) {
    super(props)

    window.addEventListener('unhandledrejection', (promiseRejectionEvent) => { 
      this.setState({ error: promiseRejectionEvent })
    })

    this.state = {
      error: null,
      errorEventId: null,
      notFound: null,
    }
  }

  componentDidCatch(error, errorInfo) {
    this.setState({ error })
    Sentry.withScope((scope) => {
      Object.keys(errorInfo).forEach((key) => {
        scope.setExtra(key, errorInfo[key])
      })
      const errorEventId = Sentry.captureException(error)
      this.setState({ errorEventId })
    })
  }

  handleContentNotFound = (location) => {
    this.setState({ notFound: location })
  }

  notFoundRouteRender = (props) => {
    this.handleContentNotFound(window.location)
    return null
  }

  render() {
    if (this.state.error) {
      return <ErrorPage error={this.state.error} errorEventId={this.state.errorEventId} />
    } else if (this.state.notFound) {
      return <NotFoundPage location={this.state.notFound} />
    }

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
              <Switch>
                <Route exact path="/repos" component={RepoIndexPage} />
                <Route exact path="/repos/new" component={AddRepoPage} />
                <Route
                  path="/:type(gh)/:name*"
                  render={(props) => <RepoPage {...props} onContentNotFound={this.handleContentNotFound} />}
                />
                <Route
                  exact
                  path="/gimme-error"
                  render={(props) => <ErrorTestPage {...props} onContentNotFound={this.handleContentNotFound} />}
                />
                <Route component={this.notFoundRouteRender} />
              </Switch>
            </div>
          </div>
        </React.Fragment>
      </Router>
    )
  }
}

export default App
