$ ->
  window.handler = null
  window.$cromos = $('#news')
  window.cards_page = 0
  window.cromoptions =
    offset: 20
    autoResize: true
    itemWidth: 300
    containerWidth: 1400
    container: window.$cromos

  window.checkScrollPosition = () ->
    window.moreCards() if (!window.ajax_cards && ($(window).scrollTop() + $(window).height() > $(document).height() - 100))
    true

  $(window).scroll ->
    window.checkScrollPosition()
    true

  # $(window).resize ->
  #   window.resizing = true
  #   clearTimeout(window.resizeTimer) if (window.resizeTimer)
  #   window.resizeTimer = setTimeout window.fullWookmark, 1000
  #   true
  # true

  window.fullWookmark = () ->
    window.handler = $('div.cell_article', window.$cromos)
    window.handler.wookmark(window.cromoptions)
  true

  window.adjustLoadDelay = () ->
    c = setTimeout('window.ajax_cards = false;  $("#spinner").hide();   window.checkScrollPosition();', 500)
    true

  window.checkScrollPosition = () ->
    window.moreCards() if (!window.ajax_cards && ($(window).scrollTop() + $(window).height() > $(document).height() - 100))
    true


  window.moreCards = ->
    unless window.ajax_cards || window.cards_page == 2
      window.ajax_cards = true
      $('#spinner').show()
      cards_html = $('#news').html()
      window.$cromos.append(cards_html)
      window.more_cards = true
      window.handler = $('.cell_article', window.$cromos)
      window.cards_page++ unless cards_html is ""
      window.handler.wookmark(window.cromoptions)
      window.adjustLoadDelay()
  true



  setTimeout(->
    $('.logo').addClass('end')
    setTimeout(->
      window.fullWookmark()
    , 1000)
  , 500)

  $('.cell_article .count_comment').click ->
    $(this).parents('.cell_article').addClass('hover')
    return false
  $('.back .button').click ->
    $(this).parents('.cell_article').removeClass('hover')
    return false




