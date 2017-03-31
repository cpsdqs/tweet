EventEmitter = require 'events'

module.exports =
  # Abstraction class for custom elements
  class UIView extends HTMLElement
    constructor: ->
      super()

      # extend EventEmitter for better events
      Object.assign this, EventEmitter.prototype
      EventEmitter.prototype.constructor.apply this

    # add elements quickly without much syntax
    addTo: (query, elements...) ->
      # if there's no query add to self
      if typeof query is 'string'
        el = @querySelector query
      else
        el = this
        # add query to elements
        elements.unshift query

      # only try adding if queried element exists
      if el
        for element in elements
          if Array.isArray element
            # for [className, element] syntax
            el.className += element[0].replace(/\./g, ' ')
            el.appendChild element[1]
          else if element instanceof Node
            el.appendChild element
          else
            # for { className: element } syntax
            for classes, node of element
              node.className += classes.replace(/\./g, ' ')
              el.appendChild node

    # emit a connected event to allow multiple listeners
    connectedCallback: ->
      @emit 'connected'

    # emit a disconnected event to allow multiple listeners
    disconnectedCallback: ->
      @emit 'disconnected'
