// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require('raf').polyfill()
import 'core-js/stable';
import 'regenerator-runtime/runtime';
import 'whatwg-fetch'
import 'intl'
import 'lib/polyfills/dataset'
import * as Sentry from '@sentry/browser'
import ReactRailsUJS from 'react_ujs'

if (window.SentryConfig) {
  const SentryConfig = window.SentryConfig

  Sentry.init({
    dsn: SentryConfig.dsn,
    environment: SentryConfig.environment,
    release: SentryConfig.release,
    beforeBreadcrumb(breadcrumb, hint) {
      // This method gives us a chance to modify or discard breadcrumbs.

      if (breadcrumb.category === 'xhr' || breadcrumb.category === 'fetch') {
        if (SentryConfig.xhrUrlIgnorePattern.test(breadcrumb.data.url)) {
          return null
        }
      }

      return breadcrumb
    },
  })
  Sentry.configureScope((scope) => {
    scope.setUser(SentryConfig.user)
    if (SentryConfig.actingForUser) {
      scope.setTag('acting_for_user_id', SentryConfig.actingForUser.id)
      scope.setTag('acting_for_user', SentryConfig.actingForUser.email)
    }
  })
}

const componentRequireContext = require.context('components', true)
ReactRailsUJS.useContext(componentRequireContext)
