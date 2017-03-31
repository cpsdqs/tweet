View = require './view'
Label = require './label'
Icon = require './icon'
IconButton = require './icon-button'
EntityText = require './entity-text'
ipc = require './ipc'
twitter = require './twitter-interface'
{ remote: { Menu, MenuItem } } = require 'electron'

class Tweet extends View
  constructor: (tweet) ->
    super()

    @headerText = new Label
    @name = new Label
    @verified = new Icon 'verified'
    @username = new Label
    @buttons =
      reply: new IconButton 'reply'
      like: new IconButton 'like'
      retweet: new IconButton 'retweet'

    @avatar = new Image

    @content = new EntityText

    @fromTweet tweet

    @once 'connected', =>
      @innerHTML = """
        <header class="tweet-header"></header>
        <div class="tweet-flex">
          <div class="left"></div>
          <div class="content">
            <header class="content-header"></header>
            <div class="content-main"></div>
            <footer class="tweet-footer"></footer>
          </div>
        </div>
      """

      @addTo '.left',
        avatar: @avatar
      @addTo '.tweet-header',
        text: @headerText
      @addTo '.content-header',
        name: @name
        verified: @verified
        username: @username
      @addTo '.tweet-footer',
        reply: @buttons.reply
        retweet: @buttons.retweet
        like: @buttons.like
      @addTo '.content-main',
        'tweet-content': @content

      if tweet.retweeted_status
        @headerText.text = "#{tweet.user.name} retweeted"
        @classList.add 'retweeted'

    @buttons.reply.addEventListener 'click', (e) =>
      ipc.send 'open-window', 'compose', replyTo: @tweet.id_str

    @buttons.like.addEventListener 'click', (e) =>
      command = 'favTweet'
      command = 'unfavTweet' if @tweet.favorited
      twitter.request(twitter.account, command, @tweet.id_str).then (res) =>
        console.log @, res
        @fromTweet res

  @get contextMenu: ->
    items = []

    # add reply, like [and retweet when that's implemented]
    # TODO: move reply and like into extra methods
    items.push new MenuItem
      label: "Reply to #{@tweet.user.name}"
      click: => @buttons.reply.click()
    items.push new MenuItem
      label: "#{if @tweet.favorited then 'Unl' else 'L'}ike Tweet"
      click: => @buttons.like.click()

    # add delete if this is an own tweet
    if @tweet.user.id_str is twitter.account
      items.push new MenuItem
        label: 'Delete',
        click: =>
          twitter.request twitter.account, 'deleteTweet', @tweet.id_str
    items

  fromTweet: (tweet) ->
    @tweet = tweet
    @name.text = tweet.user.name
    @verified.hidden = not tweet.user.verified
    @username.text = tweet.user.screen_name
    @avatar.src = tweet.user.profile_image_url_https.replace /normal/, 'bigger'

    @content.text = tweet.text ? tweet.full_text ? '!!!NO TWEET TEXT?!!'
    @content.entities = tweet.entities ? {}
    @content.extendedEntities = tweet.extended_entities ? {}
    if tweet.extended_tweet
      @content.text = tweet.extended_tweet.full_text
      @content.entities = tweet.extended_tweet.entities ? {}
      @content.extendedEntities = tweet.extended_tweet.extended_entities ? {}
    if tweet.quoted_status
      @content.quoted = new Tweet tweet.quoted_status
    @content.update()

    if tweet.favorited
      @buttons.like.classList.add 'liked'
    else
      @buttons.like.classList.remove 'liked'

    @setAttribute 'tweet-id', tweet.id_str

    if tweet.retweeted_status
      @content = new Tweet tweet.retweeted_status

    @headerText.text = ''

    if tweet.in_reply_to_status_id
      @headerText.text = "In reply to #{tweet.in_reply_to_screen_name}"

    sourceContainer = document.createElement 'div'
    sourceContainer.innerHTML = tweet.source
    tweetSource = sourceContainer.firstChild.textContent ? '?'
    @headerText.text += " via #{tweetSource}"
    @headerText.text += " at #{new Date(tweet.created_at).toISOString()}"

    if tweet.truncated and not tweet.extended_tweet and not @req
      twitter.request(twitter.account, 'getTweet', tweet.id_str).then (res) =>
        console.log res
        @req = true
        @fromTweet res
      .catch (err) ->
        console.error err


customElements.define 'ui-tweet', Tweet
module.exports = Tweet
