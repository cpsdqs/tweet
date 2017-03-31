{ app, BrowserWindow, ipcMain: ipc } = require 'electron'
path = require 'path'
url = require 'url'
Window = require './window'

windows = Window.windows

app.on 'ready', ->
  users = require './users'
  require './twitter-interface'

  if users.count
    new Window 'home'
