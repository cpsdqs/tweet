View = require './view'
Media = require './media'

decodeEntities = (s) ->
  div = document.createElement 'div'
  s.replace /&[\w\d#]+;/g, (m) ->
    div.innerHTML = m
    div.textContent

# text with entities
class EntityText extends View
  constructor: ->
    super()

    @text = ''
    @entities = {}
    @extendedEntities = {}
    @quoted = null
    @content = document.createElement 'div'
    @content.className = 'entity-text-content'
    @once 'connected', ->
      @appendChild @content

  update: ->
    startIndices = {}
    endIndices = {}
    indices = new Set
    for type, list of @entities
      for entity in list
        [start, end] = entity.indices
        startIndices[start] = [] if not startIndices[start]
        endIndices[end] = [] if not endIndices[end]
        entity.entityType = type
        startIndices[start].push entity
        endIndices[end].push entity
        indices.add start
        indices.add end

    text = []
    # need to iterate through characters because emoji
    for char in @text[Symbol.iterator]().iterate()
      text.push char

    quotedID = ''
    if @quoted
      quotedID = @quoted.tweet.id_str

    media = document.createElement 'div'
    media.classList.add 'media'

    indices.add text.length
    indices = indices.iterate().sort((a, b) -> a - b)
    entities = []
    lastIndex = 0
    parts = []
    for index in indices
      if entities.length is 1 and entities[0].entityType is 'urls'
        urlre = /^https?:\/\/twitter\.com\/[\w_]+?\/status\/\d+$/
        if entities[0].expanded_url.match urlre
          if entities[0].expanded_url.match(/(\d+)\/?$/)[1] is quotedID
            continue
      parts.push
        content: text.slice(lastIndex, index).join ''
        start: lastIndex
        end: index
        entities: entities.slice()
      lastIndex = index
      if startIndices[index]
        entities.push entity for entity in startIndices[index]
      if endIndices[index]
        for entity in endIndices[index]
          entities.splice entities.indexOf(entity), 1

    # remove media indices
    mediaCount = 0
    for type, list of @extendedEntities
      for entity in list
        if type is 'media'
          for part, i in parts
            if part.start is entity.indices[0] and part.end is entity.indices[1]
              parts.splice i, 1
              break
          media.appendChild new Media entity
          mediaCount++

    @content.innerHTML = ''
    for part in parts
      span = document.createElement 'span'
      @content.appendChild span
      span.innerText = decodeEntities part.content
      for entity in part.entities
        span.classList.add entity.entityType
        switch entity.entityType
          when 'media'
            anchor = document.createElement 'a'
            anchor.href = entity.expanded_url
            anchor.innerText = decodeEntities entity.display_url
            span.innerText = ''
            span.appendChild anchor
          when 'urls'
            anchor = document.createElement 'a'
            anchor.href = entity.expanded_url
            anchor.setAttribute 'short', entity.url
            anchor.innerText = decodeEntities entity.display_url
            span.innerText = ''
            span.appendChild anchor

    if @quoted
      container = document.createElement 'div'
      container.classList.add 'quoted-tweet-container'
      @content.appendChild container
      @quoted.parentNode.removeChild @quoted if @quoted.parentNode
      container.appendChild @quoted

    @content.appendChild media
    media.classList.add "media-#{mediaCount}"


customElements.define 'ui-entity-text', EntityText
module.exports = EntityText
