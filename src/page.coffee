View = require './view'
Label = require './label'
IconButton = require './icon-button'
Stream = require './stream'
twitter = require './twitter-interface'

class Page extends View
  constructor: ->
    super()

    @headerTitle = new Label
    @headerTitle.text = 'Title'
    @backButton = new IconButton 'back'
    @pages = []
    @container = document.createElement 'div'
    @container.classList.add('page-inner')

    @once 'connected', ->
      @innerHTML = """
      <header class="page-header">
        <div class="button-group navigation"></div>
      </header>
      """

      @addTo '.page-header',
        title: @headerTitle
      @addTo '.navigation',
        back: @backButton
      @addTo @container

    @backButton.addEventListener 'click', (e) =>
      @popState() if @pages.length > 1

  pushState: (page) ->
    if @pages[@pages.length - 1] isnt page
      @pages.push page
      @update()

  popState: ->
    value = @pages.splice @pages.length - 1
    @update()
    value[0]

  update: ->
    for child in @container.children
      @container.removeChild child

    @container.appendChild @pages[@pages.length - 1]

customElements.define 'ui-page', Page
module.exports = Page
