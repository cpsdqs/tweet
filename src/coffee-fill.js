// for use with static (e.g. @static get prop: -> ...)
global.get = function (properties) {
  return ['get', properties]
}
global.set = function (properties) {
  return ['set', properties]
}

let bind = (value, context) => {
  if (value instanceof Function) return value.bind(context)
  return value
}

Object.defineProperties(Function.prototype, {
  get: {
    value: function (properties) {
      for (property in properties) {
        Object.defineProperty(this.prototype, property, {
          get: properties[property],
          configurable: true
        })
      }
    },
    configurable: true,
    writable: true
  },
  set: {
    value: function (properties) {
      for (property in properties) {
        Object.defineProperty(this.prototype, property, {
          set: properties[property],
          configurable: true
        })
      }
    },
    configurable: true,
    writable: true
  },
  static: {
    value: function ([type, properties]) {
      for (property in properties) {
        Object.defineProperty(this, property, {
          [type]: bind(properties[property], this),
          configurable: true
        })
      }
    },
    configurable: true,
    writable: true
  }
})

iteratorPrototype = {
  iterate: {
    value: function (max = Infinity) {
      let contents = []
      for (element of this) {
        if (contents.length >= max) break;
        contents.push(element)
      }
      return contents
    },
    configurable: true,
    writable: true
  }
}
// there's no Generator prototype for some reason
// Object.defineProperties(Function.prototype, iteratorPrototype)

// for Symbol.iterator
Object.defineProperties(Object.prototype, iteratorPrototype)
