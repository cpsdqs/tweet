config = require './config'
Window = require './window'

# check if there are any users
userCount = 0
for user of config.get 'accounts'
  userCount++

# if there are none, open login window
if userCount is 0
  loginWindow = new Window 'login'

module.exports =
  count: userCount
