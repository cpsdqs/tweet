Config = require 'electron-config'
config = new Config
  defaults: require './default-config'
  name: 'tweet-config'

module.exports = config
