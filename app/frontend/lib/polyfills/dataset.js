// taken from https://github.com/discontinued/element-dataset/blob/master/src/index.js

if (!document.documentElement.dataset &&
  (
    !Object.getOwnPropertyDescriptor(HTMLElement.prototype, 'dataset') ||
    !Object.getOwnPropertyDescriptor(HTMLElement.prototype, 'dataset').get
  )
) {
  const descriptor = {}

  descriptor.enumerable = true

  descriptor.get = function get() {
    const element = this
    const map = {}
    const { attributes } = this

    function toUpperCase(n0) {
      return n0.charAt(1).toUpperCase()
    }

    function getter() {
      return this.value
    }

    function setter(name, value) {
      if (typeof value !== 'undefined') {
        this.setAttribute(name, value)
      } else {
        this.removeAttribute(name)
      }
    }

    for (let i = 0; i < attributes.length; i += 1) {
      const attribute = attributes[i]

      // This test really should allow any XML Name without
      // colons (and non-uppercase for XHTML)

      if (attribute && attribute.name && (/^data-\w[\w-]*$/).test(attribute.name)) {
        const { name, value } = attribute

        // Change to CamelCase

        const propName = name.substr(5).replace(/-./g, toUpperCase)

        Object.defineProperty(map, propName, {
          enumerable: descriptor.enumerable,
          get: getter.bind({ value: value || '' }),
          set: setter.bind(element, name),
        })
      }
    }
    return map
  }

  Object.defineProperty(HTMLElement.prototype, 'dataset', descriptor)
}
