$(document).ready ->

  # This file is only needed if the current view is live_results#show
  if $('div.live-results').length > 0

    window.liveScroll = ->

      # horizontal and vertical scroll increments
      window.scrollBy 0, 1

      # scroll rate in milliseconds
      scrolldelay = setTimeout('liveScroll()', 50)

      # Once we reach the bottom, pause and then rewind
      if window.innerHeight + window.pageYOffset >= document.body.offsetHeight
        clearTimeout(scrolldelay)
        scrolldelay = setTimeout('liveRewind()', 5000)

    window.liveRewind = ->
      window.scrollTo 0, 0
      setTimeout('liveScroll()', 50)


    liveScroll()
