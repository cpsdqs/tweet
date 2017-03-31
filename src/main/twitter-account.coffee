Twitter = require 'twitter'
stream = require 'stream'
stringify = require 'json-stable-stringify'
TweetStream = require './tweet-stream'

module.exports =
  class TwitterAccount
    constructor: (args) ->
      @client = new Twitter
        access_token_key: args.accessKey
        access_token_secret: args.accessSecret
        consumer_key: args.consumerKey
        consumer_secret: args.consumerSecret

      @streams = {}
      @cache = {}

    serialize: ->
      @client.options

    verify: ->
      new Promise (resolve, reject) =>
        @client.get('account/verify_credentials').then (data) ->
          resolve data
        .catch (err) ->
          reject err

    getTweets: (url = 'statuses/home_timeline', options) ->
      new Promise (resolve, reject) =>
        @client.get url,
          count: options?.count ? 100
          include_entities: options?.includeEntities ? true
          tweet_mode: options?.tweetMode ? 'extended'
        .then (data) ->
          resolve data
        .catch (err) ->
          reject err

    streamTweets: (url = 'user', options = { with: 'followings' }) ->
      name = "#{url}:#{stringify options}"

      if not (name of @streams)
        console.log 'creating tweet stream', url, options
        @streams[name] = new TweetStream @client, url, options

      @streams[name]

    tweet: (tweet) ->
      new Promise (resolve, reject) =>
        data =
          status: tweet.text
        data.media_ids = tweet.media if tweet.media
        data.in_reply_to_status_id = tweet.replyTo if tweet.replyTo
        @client.post('statuses/update', data).then (res) ->
          resolve res
        .catch (err) ->
          reject err

    favTweet: (id) ->
      new Promise (resolve, reject) =>
        options =
          id: id
          tweet_mode: 'extended'
        @client.post('favorites/create', options).then (data) ->
          resolve data
        .catch (err) ->
          reject err

    unfavTweet: (id) ->
      new Promise (resolve, reject) =>
        options =
          id: id
          tweet_mode: 'extended'
        @client.post('favorites/destroy', options).then (data) ->
          resolve data
        .catch (err) ->
          reject err

    deleteTweet: (id) ->
      new Promise (resolve, reject) =>
        options =
          id: id
          tweet_mode: 'extended'
        @client.post("statuses/destroy/#{id}", options).then (data) ->
          resolve data
        .catch (err) ->
          reject err

    retweetTweet: (id) ->
      new Promise (resolve, reject) =>
        options =
          id: id
          tweet_mode: 'extended'
        @client.post("statuses/retweet/#{id}", options).then (data) ->
          resolve data
        .catch (err) ->
          reject err

    unretweetTweet: (id) ->
      new Promise (resolve, reject) =>
        options =
          id: id
          tweet_mode: 'extended'
        @client.post("statuses/unretweet/#{id}", options).then (data) ->
          resolve data
        .catch (err) ->
          reject err

    mediaUpload: (options) ->
      new Promise (resolve, reject) =>
        @client.post('media/upload', options).then (data) ->
          resolve data
        .catch (err) ->
          reject err

    getTweet: (id, options) ->
      options =
        id: id
        tweet_mode: 'extended'
      options.trim_user = options?.trimUser if options?.trimUser
      options.include_my_retweet =
        options?.includeRetweet if options?.includeRetweet
      options.include_entities = options?.includeEntities ? true
      new Promise (resolve, reject) =>
        @client.get("statuses/show/#{id}", id: id).then (data) ->
          resolve data
        .catch (err) ->
          reject err
