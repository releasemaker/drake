import CsrfUtil from 'lib/CsrfUtil'

export default function fetch(url, options) {
  return window.fetch(
    url,
    {
      ...options,
      credentials: 'same-origin',
      headers: {
        ...options.headers,
        'content-type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CsrfUtil.getToken(),
      },
    }
  )
}
