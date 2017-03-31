View = require './view'
ipc = require './ipc'
Label = require './label'
upload = require './upload'
twitter = require './twitter-interface'
fs = require 'fs'

class Compose extends View
  constructor: (args) ->
    super()

    @args = args ? {}

    @composeTitle = new Label
    @composeTitle.text = 'New Tweet'
    @content = document.createElement 'div'
    @content.contentEditable = true
    @submitButton = document.createElement 'button'
    @submitButton.textContent = 'Tweet'
    @characterCount = new Label
    @characterCount.text = '140'
    @inReplyTo = document.createElement 'input'
    @inReplyTo.placeholder = 'In Reply To ID'

    @inReplyTo.value = @args.replyTo if @args.replyTo

    @once 'connected', =>
      @innerHTML = """
      <header class="compose-header"></header>
      <div class="compose-wrap">
        <div class="account"></div>
        <div class="content-wrap"></div>
      </div>
      <footer class="compose-footer"></footer>
      """

      @addTo '.compose-header', title: @composeTitle
      @addTo '.content-wrap', 'in-reply-to': @inReplyTo
      @addTo '.content-wrap', content: @content
      @addTo '.compose-footer',
        'char-count': @characterCount
        'submit-button': @submitButton

      @content.focus()

    # HACK: remove styles
    @content.addEventListener 'mousemove', (e) =>
      # keyup messes up some stuff
      @content.innerText = @content.innerText
    @submitButton.addEventListener 'click', (e) =>
      text = @content.innerText
      if text.length > 140
        # TODO: post reply chain
        return

      @content.contentEditable = false

      replyToID = @inReplyTo.value

      rtext = text
      matches = []
      index = 0
      while match = rtext.match /!%(.+?)%!/
        matches.push {
          match: match
          content: match[1]
          start: index + match.index
          end: index + match.index + match[0].length
        }
        index += match.index + match[0].length
        rtext = text.substr index

      rtext = text.replace /!%.+?%!/g, ''

      console.log matches

      files = []
      fileIDs = []
      for file in matches
        [content, type, path] = file.content.match /(\w+\/\w+)\|(.+)/
        file = fs.readFileSync path
        files.push new Promise (resolve, reject) ->
          upload(twitter.account, type, file).then (res) ->
            console.log res
            fileIDs.push res
            resolve res
          .catch (err) ->
            console.error err
            reject err

      Promise.all(files).then =>
        twitter.request twitter.account, 'tweet',
          text: rtext
          media: fileIDs.join ','
          replyTo: replyToID
        .then (res) =>
          console.log res
          @content.contentEditable = true
      .catch (err) =>
        console.error err
        @content.contentEditable = true

customElements.define 'window-compose', Compose
module.exports = Compose

ipc.on 'window-compose', (args) ->
  document.body.appendChild new Compose args
