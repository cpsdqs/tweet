View = require './view'
Label = require './label'
twitter = require './twitter-interface'
Tweet = require './tweet'
TwitterEvent = require './event'
stringify = require 'json-stable-stringify'

streams = {}

class Stream extends View
  constructor: (account, url, options = {}, prev = '') ->
    super()

    @message = new Label
    @filter = -> true

    options.stall_warnings = true

    @once 'connected', ->
      @addTo 'error-message': @message

    if prev
      twitter.request(account, 'getTweets', prev).then (tweets) =>
        for tweet in tweets
          @appendChild new Tweet tweet
      .catch (err) =>
        console.log err
        @message.text = err[0].message

      @message.text = 'Loading...'
      name = "#{url}:#{stringify options}"
      if not streams[name]?
        console.log "created stream #{name}"
        streams[name] = twitter.stream(account, url, options)
      @initStream streams[name]

  initStream: (promise) ->
    promise.then (stream) =>
      @message.text = ''
      @stream = stream
      @stream.on 'data', (data) =>
        @message.text = ''
        if @filter data
          if data.type is 'data'
            @insertBefore new Tweet(data.data), @firstChild
          else if data.type is 'event'
            @insertBefore new TwitterEvent(data.data), @firstChild
          else console.warn 'unhandled data', data
      @stream.on 'error', (e) =>
        console.log 'error', e
        @message.text += '; ' if @message.text
        @message.text += e


customElements.define 'ui-stream', Stream
module.exports = Stream
