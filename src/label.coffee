View = require './view'

class Label extends View
  @get text: ->
    @textContent

  @set text: (value) ->
    @textContent = value

customElements.define 'ui-label', Label
module.exports = Label
