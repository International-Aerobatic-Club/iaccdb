$(document).ready ->

  # This file is only needed if the current view is live_results#show
  if $('div#last-refresh-time').length == 0
    return


  window.liveScroll = ->

    # Horizontal and vertical scroll increments
    window.scrollBy 0, 1

    # Once we reach the bottom, pause and then rewind
    # if window.innerHeight + window.pageYOffset >= document.body.offsetHeight
    if window.innerHeight + window.scrollY > document.body.offsetHeight
      clearTimeout(scrolldelay)
      scrolldelay = setTimeout('liveRewind()', 8000)
    else
      # Scroll rate in milliseconds
      scrolldelay = setTimeout('liveScroll()', 50)



  window.liveRewind = ->
    window.scrollTo 0, 0
    lastUpload()
    setTimeout('liveScroll()', 50)

  window.lastUpload = ->

    url = window.location.href
    recnum = url.substring(url.lastIndexOf('/') + 1)

    $.ajax
      type: 'GET'
      url: "/last_upload/#{recnum}.js"
      error: ->
        $('p.alert').html('Internal error while retrieving last upload time')
      success: (data, textStatus, jqXHR) ->
        # Reload the page if new results have come in
        if (Number($('div#latest-results-time').text()) > Number($('div#last-refresh-time').text()))
          alert('Reloading!') # !!!
          location.reload()

  liveScroll()
