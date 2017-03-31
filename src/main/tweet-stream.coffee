EventEmitter = require 'events'
twitter = require 'twitter'
streamEvents = [
  'close'
  'data'
  'end'
  'error'
  'readable'
  # additional from `twitter`
  'event'
  'friends'
  'delete'
]

module.exports =
  class TweetStream extends EventEmitter
    constructor: (client, url, options) ->
      super()

      @client = client
      @url = url
      @options = options

      # event listeners (event forwarding)
      @emitters = {}
      for event in streamEvents
        do (event) =>
          @emitters[event] = (args...) => @emit event, args...

      @on 'error', (err) =>
        @reconnect()

      @connect()

    setSource: (source) ->
      if @source
        # remove event listeners from previous source
        for event in streamEvents
          @source.removeListener event, @emitters[event]

      # set new source
      @source = source

      # add event listeners to new source
      for event in streamEvents
        @source.on event, @emitters[event]

    connect: ->
      try
        @setSource @client.stream @url, @options
      catch err
        console.log err
        @emit 'error', err

    reconnect: ->
      setTimeout =>
        @connect()
      , 1000

    pipe: (destination) ->
      # simple pipe
      @on 'data', (data) -> destination.write { type: 'data', data }
      @on 'event', (data) -> destination.write { type: 'event', data }
      @on 'friends', (data) -> destination.write { type: 'friends', data }
      @on 'delete', (data) -> destination.write { type: 'delete', data }

      destination
