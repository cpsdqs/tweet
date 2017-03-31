require './ipc'
require './login'
require './home'
require './compose'

document.body.classList.add "platform-#{process.platform}"

window.interface = require './twitter-interface'
