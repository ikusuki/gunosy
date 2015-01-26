$ ->
  window.handler = null
  window.$cromos = $('#news')
  window.cromoptions =
    offset: 20
    autoResize: true
    itemWidth: 300
    containerWidth: 1400
    container: window.$cromos

  # window.checkScrollPosition = () ->
  #   window.moreCards() if (!window.ajax_cards && ($(window).scrollTop() + $(window).height() > $(document).height() - 100))
  #   true

  # $(window).scroll ->
  #   window.checkScrollPosition()
  #   true

  # $(window).resize ->
  #   window.resizing = true
  #   clearTimeout(window.resizeTimer) if (window.resizeTimer)
  #   window.resizeTimer = setTimeout window.fullWookmark, 1000
  #   true
  # true

  window.fullWookmark = () ->
    # $('#spinner').addClass('resizing').show()
    window.handler = $('div.cell_article', window.$cromos)
    window.handler.wookmark(window.cromoptions)
    # $('#spinner').removeClass('resizing').hide()
  true

  window.adjustLoadDelay = () ->
    c = setTimeout('window.ajax_cards = false;  $("#spinner").hide();   window.checkScrollPosition();', 500)
    true

  # window.checkScrollPosition = () ->
  #   window.moreCards() if (!window.ajax_cards && ($(window).scrollTop() + $(window).height() > $(document).height() - 100))
  #   true

  window.fullWookmark()

  $('.cell_article .count_comment').click ->
    $(this).parents('.cell_article').addClass('hover')
    return false
  $('.back .button').click ->
    $(this).parents('.cell_article').removeClass('hover')
    return false




