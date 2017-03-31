EventEmitter = require 'events'
{ ipcRenderer: ipc } = require 'electron'

emitter = module.exports = new EventEmitter

ipc.on 'event', (e, event, data...) ->
  console.log e, event, data
  if event is 'ipc-init'
    emitter.ipcID = data[0]
    emitter.windowType = data[1]
    emitter.windowArgs = data[2] ? {}
    emitter.emit "window-#{data[1]}", data[2]
  else
    emitter.emit event, data...

emitter.send = (event, data...) ->
  ipc.send 'event', emitter.ipcID, event, data...
