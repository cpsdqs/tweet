twitter = require './twitter-interface'

# for uploading stuff to twitter

# request wrapper
post = (account, options) ->
  return new Promise (resolve, reject) ->
    twitter.request(account, 'mediaUpload', options).then (data) ->
      resolve data
    .catch (err) ->
      reject err

# chunk size is 1MiB, which should be fine probably?
chunkSize = 2 ** 20

# recursive chunked upload
chunkedUpload = (account, id, data, callback, i = 0) ->
  # get chunk from first slice
  chunk = data.slice 0, chunkSize
  # put rest in data
  data = data.slice chunkSize

  # post APPEND
  post account,
    command: 'APPEND'
    media_id: id
    media: chunk
    segment_index: i
  .then (res) ->
    if data.length
      # recursive call
      chunkedUpload account, id, data, callback, i + 1
    else
      callback res
  .catch (err) ->
    throw err

module.exports = (account, type, data) ->
  return new Promise (resolve, reject) ->
    # init
    post account,
      command: 'INIT'
      total_bytes: data.length
      media_type: type
    .then (res) ->
      # upload rest using ID
      id = res.media_id_string

      chunkedUpload account, id, data, (res) ->
        # finalize and resolve
        post account,
          command: 'FINALIZE'
          media_id: id
        .then (res) ->
          resolve id
    .catch (err) ->
      reject err
