EventEmitter = require 'events'
path = require 'path'
url = require 'url'
{ BrowserWindow, ipcMain: ipc, shell } = require 'electron'
windowTypes = require './windows'

windows = new Set

module.exports =
  class Window extends EventEmitter
    constructor: (type, args) ->
      super()

      @type = type ? ''
      @args = args
      @ipcID = Math.random().toString 16
      @window = new BrowserWindow Object.assign {}, windowTypes[type] ? {},
        show: false

      windows.add this

      @window.loadURL url.format
        pathname: path.join __dirname, '..', '..', 'index.html'
        protocol: 'file:'
        slashes: true

      @window.on 'ready-to-show', => @window.show()

      @window.webContents.on 'did-finish-load', =>
        @send 'ipc-init', @ipcID, @type, @args

      @window.webContents.on 'will-navigate', (e, url) ->
        e.preventDefault()
        shell.openExternal url

      @on 'open-window', (type, args) ->
        new Window type, args

    send: (event, data...) ->
      @window.webContents.send 'event', event, data...

    @static get windows: -> windows

ipc.on 'event', (e, id, data...) ->
  for window in windows.iterate()
    if window.ipcID is id
      window.emit data...
