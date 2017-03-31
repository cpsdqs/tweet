const fs = require('fs')
const path = require('path')
const CoffeeScript = require('coffeescript')

require('./coffee-fill')

Object.defineProperty(require.extensions, '.coffee', {
  enumerable: true,
  writable: false,
  value: function (module, filePath) {
    filePath = path.normalize(filePath)
    let code = fs.readFileSync(filePath, 'utf8')
    let displayPath = filePath.split(__dirname).join('tweet')
    return module._compile(CoffeeScript.compile(code, {
      filename: displayPath,
      sourceFiles: [displayPath],
      inlineMap: true
    }), filePath)
  }
})
