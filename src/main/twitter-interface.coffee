{ ipcMain: ipc, BrowserWindow } = require 'electron'
TwitterAccount = require './twitter-account'
config = require './config'
IPCStream = require 'electron-ipc-stream'

# used for IPC communication
class TwitterInterface
  # accounts in constructor
  # this means adding an account requires restart!
  # also it makes a bunch of stuff easier
  constructor: (accounts) ->
    # account data
    @accountData = accounts

    # account instances
    @accounts = {}

    # create instances of all accounts
    for k, acc of @accountData
      @accounts[acc.account.id_str] = new TwitterAccount acc

    # listen for `twitter` event
    ipc.on 'twitter', (e, id, data) =>
      # returns the accounts list
      if data.command is 'accounts'
        # serialize accounts using .serialize
        serialized = {}
        for aid, acc of @accounts
          serialized[aid] = acc.serialize()
        @callback e, id, true, serialized
      else if data.command is 'login'
        [key, secret, ckey, csecret] = data.args
        account = new TwitterAccount
          accessKey: key
          accessSecret: secret
          consumerKey: ckey
          consumerSecret: csecret
        account.verify().then (res) =>
          @callback e, id, true, res
        .catch (err) =>
          @callback e, id, false, err
      else if data.account? and @accounts[data.account]?
        # account exists!
        account = @accounts[data.account]

        if data.type is 'stream'
          # return a stream
          tweetStream = account.streamTweets(data.args...)
          browserWindow = BrowserWindow.fromWebContents e.sender
          ipcStream = new IPCStream id, browserWindow
          console.log 'piping tweet stream'
          tweetStream.pipe ipcStream
          @callback e, id, true, id
        else if account[data.command]?
          # return whatever the method returns
          account[data.command](data.args...).then (res) =>
            @callback e, id, true, res
          .catch (err) =>
            @callback e, id, false, err
        else @callback e, id, false, [{ message: 'No such command' }]
      else @callback e, id, false, [{ message: 'Invalid account' }]

  # resolves a promise in the renderer process (probably)
  callback: (e, id, resolved, data) ->
    e.sender.send 'twitter', 'callback', id, resolved, data

mainInterface = new TwitterInterface config.get 'accounts'
module.exports = mainInterface
