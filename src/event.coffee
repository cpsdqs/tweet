View = require './view'
Label = require './label'

# TODO: twitter event (e.g. favorite)
class TwitterEvent extends View
  constructor: (event) ->
    super()

    @text = new Label

    @event = event

    @text.text = "Event type: #{@event.event}"
    @text.text += " Time: #{new Date(@event.created_at).toISOString()}"
    @text.text += " Target: #{@event.target}"
    @text.text += " Source: #{@event.source}"

    @once 'connected', ->
      @appendChild @text

customElements.define 'ui-twitter-event', TwitterEvent
module.exports = TwitterEvent
