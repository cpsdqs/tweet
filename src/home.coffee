View = require './view'
ipc = require './ipc'
Page = require './page'
IconButton = require './icon-button'
Stream = require './stream'
twitter = require './twitter-interface'

class Home extends View
  constructor: ->
    super()

    @composeButton = new IconButton 'compose'
    @composeButton.addEventListener 'click', (e) ->
      ipc.send 'open-window', 'compose'
    @buttons =
      timeline: new IconButton 'timeline'
      mentions: new IconButton 'mentions'
      notifications: new IconButton 'notifications'
    @content = new Page
    @timeline = new Stream twitter.account, 'user', { with: 'followings' },
      'statuses/home_timeline'
    @mentions = new Stream twitter.account, 'user', {},
      'statuses/mentions_timeline'
    @notifications = new Stream twitter.account, 'user', {}
    @content.pushState @timeline

    @timeline.filter = (data) =>
      if data.type is 'data'
        true
      else if data.type is 'delete'
        # find status and delete it
        # TODO: clean up
        for child in @timeline.children
          if child?.tweet?.id_str is data?.data?.delete?.status?.id_str
            child.classList.add 'deleted'
    @mentions.filter = (data) ->
      if data.type is 'data' and data.data.user.id_str isnt twitter.account
        true
      else false
    @notifications.filter = (data) ->
      console.log 'notification!', data
      if data.type is 'data' then false else true

    @once 'connected', ->
      @innerHTML = """
      <div class="sidebar">
        <div class="sidebar-tabs">

        </div>
      </div>
      <div class="page-container"></div>
      """

      @addTo '.sidebar', 'compose-button': @composeButton
      @addTo '.sidebar-tabs',
        'timeline-button': @buttons.timeline
        'mentions-button': @buttons.mentions
        'notifications-button': @buttons.notifications
      @addTo '.page-container', @content

      if process.platform is 'darwin' then @classList.add 'darwin'

    @buttons.timeline.addEventListener 'click', (e) =>
      @content.pushState @timeline
    @buttons.mentions.addEventListener 'click', (e) =>
      @content.pushState @mentions
    @buttons.notifications.addEventListener 'click', (e) =>
      @content.pushState @notifications

customElements.define 'window-home', Home
module.exports = Home

ipc.on 'window-home', ->
  document.body.appendChild new Home
