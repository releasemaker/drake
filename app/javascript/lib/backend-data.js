export class UnexpectedBackendResponseError extends Error {
  constructor(message) {
    super(message)
    this.name = "UnexpectedBackendResponseError"
  }
}

function getCsrfToken() {
  const token = document.querySelector('meta[name="csrf-token"]')
  return token && token.content
}

export function fetchFromBackend(url, options) {
  return window.fetch(
    url,
    {
      ...options,
      credentials: 'same-origin',
      headers: {
        ...options.headers,
        'content-type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': getCsrfToken(),
      },
    }
  )
}
