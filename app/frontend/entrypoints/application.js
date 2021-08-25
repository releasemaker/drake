import 'core-js/stable';
import 'regenerator-runtime/runtime';
import 'whatwg-fetch';
import '@lib/polyfills/dataset';
import * as Sentry from '@sentry/browser';
import React from 'react';
import ReactDOM from 'react-dom';
import App from 'components/App';

if (window.SentryConfig) {
  const SentryConfig = window.SentryConfig;

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
  });
  Sentry.configureScope((scope) => {
    scope.setUser(SentryConfig.user);
    if (SentryConfig.actingForUser) {
      scope.setTag('acting_for_user_id', SentryConfig.actingForUser.id);
      scope.setTag('acting_for_user', SentryConfig.actingForUser.email);
    }
  });
}

ReactDOM.render(React.createElement(App), document.getElementById('js-app'));
