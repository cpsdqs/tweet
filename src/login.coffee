View = require './view'
ipc = require './ipc'
twitter = require './twitter-interface'

class Login extends View
  constructor: ->
    super()

    @consumer =
      key: document.createElement 'input'
      secret: document.createElement 'input'
    @account =
      key: document.createElement 'input'
      secret: document.createElement 'input'
    @consumer.key.placeholder = 'Consumer Key'
    @consumer.secret.placeholder = 'Consumer Secret'
    @account.key.placeholder = 'Access Key'
    @account.secret.placeholder = 'Access Secret'
    @button = document.createElement 'button'
    @button.textContent = 'Login'
    @error = document.createElement 'div'

    @once 'connected', ->
      @innerHTML = """
      <div class="login-title">Login</div>
      <div class="input-section">
        <div class="section-title">Application</div>
        <div class="input-wrap consumer-key">
          <span class="input-label">Key</span>
        </div>
        <div class="input-wrap consumer-secret">
          <span class="input-label">Secret</span>
        </div>
      </div>
      <div class="input-section">
        <div class="section-title">Account</div>
        <div class="input-wrap account-key">
          <span class="input-label">Key</span>
        </div>
        <div class="input-wrap account-secret">
          <span class="input-label">Secret</span>
        </div>
      </div>
      <footer class="login-footer"></footer>
      """

      @addTo '.consumer-key', @consumer.key
      @addTo '.consumer-secret', @consumer.secret
      @addTo '.account-key', @account.key
      @addTo '.account-secret', @account.secret
      @addTo '.login-footer', button: @button, error: @error

      @consumer.key.addEventListener 'blur', =>
        @consumer.key.visited = true
        @update()
      @consumer.secret.addEventListener 'blur', =>
        @consumer.secret.visited = true
        @update()
      @account.key.addEventListener 'blur', =>
        @account.key.visited = true
        @update()
      @account.secret.addEventListener 'blur', =>
        @account.secret.visited = true
        @update()
      @consumer.key.focus()
      @update()

    @button.addEventListener 'click', =>
      @error.textContent = ''
      if @update() is 0
        @button.disabled = yes

        key = @consumer.key.value
        secret = @consumer.secret.value
        accessKey = @account.key.value
        accessSecret = @account.secret.value
        twitter.request('login', key, secret, accessKey, accessSecret)
        .then (data) =>
          @error.textContent = 'Success! Restart app now'
        .catch (err) =>
          @error.textContent = err[0].message
          @button.disabled = no
          @consumer.key.focus()
      else
        @error.textContent = 'All fields are required'

  update: (nocheck) ->
    inputs = [
      @consumer.key
      @consumer.secret
      @account.key
      @account.secret
    ]

    errors = 0
    for input in inputs
      if not input.value and input.visited or nocheck
        input.classList.add 'error'
        errors++
      else
        input.classList.remove 'error'

    errors

customElements.define 'window-login', Login
module.exports = Login

ipc.on 'window-login', ->
  document.body.appendChild new Login
