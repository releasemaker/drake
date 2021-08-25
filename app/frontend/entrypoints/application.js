// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

// Example: Load Rails libraries in Vite.
//
// import '@rails/ujs'
//
// import Turbolinks from 'turbolinks'
// import ActiveStorage from '@rails/activestorage'
//
// // Import all channels.
// import.meta.globEager('./**/*_channel.js')
//
// Turbolinks.start()
// ActiveStorage.start()

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

require('raf').polyfill()
import 'core-js/stable';
import 'regenerator-runtime/runtime';
import 'whatwg-fetch'
import 'intl'
import '@lib/polyfills/dataset'
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
