View = require './view'
Icon = require './icon'

# button with no a11y
class IconButton extends View
  constructor: (name) ->
    super()

    @icon = new Icon name

    @on 'connected', ->
      @appendChild @icon

    @addEventListener 'click', (e) ->
      @emit 'click'

customElements.define 'ui-icon-button', IconButton
module.exports = IconButton
