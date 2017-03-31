EventEmitter = require 'events'
{ ipcRenderer: ipc } = require 'electron'
IPCStream = require 'electron-ipc-stream'

# interface for interfacing with the twitter interface in the main process
# interface interface interface
class TwitterInterface extends EventEmitter
  constructor: ->
    super()

    # all pending callbacks
    @callbacks = new Map

    # all available accounts
    @accounts = {}

    # active account
    @account = null

    # request accounts
    @request(null, 'accounts', {}).then (accounts) =>
      @accounts = accounts

      # select next best account because reasons
      for id of @accounts
        @account = id

    # handle twitter event
    ipc.on 'twitter', (e, type, args...) =>
      if type is 'callback'
        # resolve callback
        [id, resolved, data] = args
        if @callbacks.has id
          callback = @callbacks.get(id)
          @callbacks.delete id
          if resolved
            callback.resolve data
          else
            callback.reject data

  request: (account, command, args...) ->
    id = Math.random().toString 16
    ipc.send 'twitter', id,
      type: 'request'
      account: account
      command: command
      args: args
    new Promise (resolve, reject) =>
      @callbacks.set id, { resolve, reject }

  stream: (account, args...) ->
    id = Math.random().toString 16
    ipc.send 'twitter', id,
      type: 'stream'
      account: account
      args: args
    new Promise (resolve, reject) =>
      # I'm not going to fake promise resolve/reject
      new Promise (res, rej) =>
        @callbacks.set id, { resolve: res, reject: rej }
      .then ->
        # stream initialized!
        resolve new IPCStream id
      .catch (err) ->
        # doesn't happen, but I'll log it anyway
        console.error err
        reject err

mainInterface = new TwitterInterface
module.exports = mainInterface
