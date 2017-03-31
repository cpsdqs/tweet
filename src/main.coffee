require './ipc'
require './login'
require './home'
require './compose'
require './context-menu'

document.body.classList.add "platform-#{process.platform}"

window.interface = require './twitter-interface'
