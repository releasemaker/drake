class CsrfUtil {
  static getToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token && token.content
  }
}

export default CsrfUtil
