View = require './view'

class Media extends View
  constructor: (media) ->
    super()

    @media = media
    @content = document.createElement 'div'
    @content.classList.add 'media-content'

    switch @media.type
      when 'photo'
        image = new Image
        image.src = @media.media_url_https
        @content.appendChild image
        # @content.style.width = @media.sizes.thumb.w + 'px'
        @content.style.height = @media.sizes.thumb.h + 'px'
        image.addEventListener 'load', =>
          if @media.sizes.thumb.resize is 'fit'
            image.classList.add 'fit'
          else
            # crop
            image.classList.add 'crop'
          containerAspect = @media.sizes.thumb.w / @media.sizes.thumb.h
          imageAspect = image.width / image.height
          if containerAspect > imageAspect
            image.classList.add 'container-width'
          else
            image.classList.add 'container-height'
      when 'video'
        video = document.createElement 'video'
        video.controls = true
        video.loop = true
        video.src = @media.video_info.variants[0].url
        @content.appendChild video

    @once 'connected', ->
      @appendChild @content

customElements.define 'ui-media', Media
module.exports = Media
