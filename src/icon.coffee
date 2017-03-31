View = require './view'
fs = require 'fs'
path = require 'path'

iconPath = path.resolve(__dirname, '..', 'assets', 'icons')

cache = new Map()

class Icon extends View
  constructor: (name) ->
    super()

    @name = name

    @once 'connected', =>
      @update()

  update: ->
    name = @name
    if cache.has name
      @innerHTML = cache.get name
    else
      fs.readFile "#{iconPath}/#{name}.svg", 'utf8', (err, file) =>
        if err
          console.error err
        else
          file = file.replace /fill=["']#000["']/g, 'fill="currentColor"'
          file = file.replace /stroke=["']#000["']/g, 'stroke="currentColor"'
          cache.set name, file
          @innerHTML = file if name is @name

  @get name: ->
    @['.name']

  @set name: (value) ->
    @['.name'] = value
    @update() if @isConnected

  @get hidden: ->
    @hasAttribute 'hidden'

  @set hidden: (value) ->
    if value
      @setAttribute 'hidden', ''
    else
      @removeAttribute 'hidden'

customElements.define 'ui-icon', Icon
module.exports = Icon
