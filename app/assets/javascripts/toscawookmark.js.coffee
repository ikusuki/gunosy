#!
#  jQuery Wookmark plugin
#  @name jquery.wookmark.js
#  @author Christoph Ono (chri@sto.ph or @gbks)
#  @author Sebastian Helzle (sebastian@helzle.net or @sebobo)
#  @version 1.4.8
#  @date 07/08/2013
#  @category jQuery plugin
#  @copyright (c) 2009-2014 Christoph Ono (www.wookmark.com)
#  @license Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
#
((factory) ->
  if typeof define is "function" and define.amd
    define ["jquery"], factory
  else
    factory jQuery
  return
) ($) ->
  animations = [
      "fadeInDown"
      "fadeInLeft"
      "fadeInRight"
      "fadeInUp"
    ]
  # Wookmark default options

  # Function for executing css writes to dom on the next animation frame if supported
  bulkUpdateCSS = (data) ->
    executeNextFrame ->
      i = undefined
      item = undefined
      i = 0
      while i < data.length
        item = data[i]
        item.obj.css item.css
        i++
      return

    return
  cleanFilterName = (filterName) ->
    $.trim(filterName).toLowerCase()
  Wookmark = undefined
  defaultOptions = undefined
  __bind_ = undefined
  __bind_ = (fn, me) ->
    ->
      fn.apply me, arguments

  defaultOptions =
    align: "center"
    autoResize: false
    comparator: null
    container: $("body")
    direction: `undefined`
    ignoreInactiveItems: true
    itemWidth: 0
    fillEmptySpace: false
    flexibleWidth: 0
    offset: 2
    outerOffset: 0
    onLayoutChanged: `undefined`
    possibleFilters: []
    resizeDelay: 50
    verticalOffset: `undefined`

  executeNextFrame = window.requestAnimationFrame or (callback) ->
    callback()
    return

  $window = $(window)

  # Main wookmark plugin class
  Wookmark = (->
    Wookmark = (handler, options) ->

      # Instance variables.
      @handler = handler
      @columns = @containerWidth = @resizeTimer = null
      @activeItemCount = 0
      @itemHeightsDirty = true
      @placeholders = []
      $.extend true, this, defaultOptions, options
      @verticalOffset = @verticalOffset or @offset

      # Bind instance methods
      @update = __bind_(@update, this)
      @onResize = __bind_(@onResize, this)
      @onRefresh = __bind_(@onRefresh, this)
      @getItemWidth = __bind_(@getItemWidth, this)
      @layout = __bind_(@layout, this)
      @layoutFull = __bind_(@layoutFull, this)
      @layoutColumns = __bind_(@layoutColumns, this)
      @filter = __bind_(@filter, this)
      @clear = __bind_(@clear, this)
      @getActiveItems = __bind_(@getActiveItems, this)
      @refreshPlaceholders = __bind_(@refreshPlaceholders, this)
      @sortElements = __bind_(@sortElements, this)
      @updateFilterClasses = __bind_(@updateFilterClasses, this)

      # Initial update of the filter classes
      @updateFilterClasses()

      # Listen to resize event if requested.
      $window.bind "resize.wookmark", @onResize  if @autoResize
      @container.bind "refreshWookmark", @onRefresh
      return
    Wookmark::updateFilterClasses = ->

      # Collect filter data
      i = 0
      j = 0
      k = 0
      filterClasses = {}
      itemFilterClasses = undefined
      $item = undefined
      filterClass = undefined
      possibleFilters = @possibleFilters
      possibleFilter = undefined
      while i < @handler.length
        $item = @handler.eq(i)

        # Read filter classes and globally store each filter class as object and the fitting items in the array
        itemFilterClasses = $item.data("filterClass")
        if typeof itemFilterClasses is "object" and itemFilterClasses.length > 0
          j = 0
          while j < itemFilterClasses.length
            filterClass = cleanFilterName(itemFilterClasses[j])
            filterClasses[filterClass] = []  if typeof (filterClasses[filterClass]) is "undefined"
            filterClasses[filterClass].push $item[0]
            j++
        i++
      while k < possibleFilters.length
        possibleFilter = cleanFilterName(possibleFilters[k])
        filterClasses[possibleFilter] = []  unless possibleFilter of filterClasses
        k++
      @filterClasses = filterClasses
      return


    # Method for updating the plugins options
    Wookmark::update = (options) ->
      @itemHeightsDirty = true
      $.extend true, this, options
      return


    # This timer ensures that layout is not continuously called as window is being dragged.
    Wookmark::onResize = ->
      clearTimeout @resizeTimer
      @itemHeightsDirty = @flexibleWidth isnt 0
      @resizeTimer = setTimeout(@layout, @resizeDelay)
      return


    # Marks the items heights as dirty and does a relayout
    Wookmark::onRefresh = ->
      @itemHeightsDirty = true
      @layout()
      return


    ###*
    Filters the active items with the given string filters.
    @param filters array of string
    @param mode 'or' or 'and'
    ###
    Wookmark::filter = (filters, mode, dryRun) ->
      activeFilters = []
      activeFiltersLength = undefined
      activeItems = $()
      i = undefined
      j = undefined
      k = undefined
      filter = undefined
      filters = filters or []
      mode = mode or "or"
      dryRun = dryRun or false
      if filters.length

        # Collect active filters
        i = 0
        while i < filters.length
          filter = cleanFilterName(filters[i])
          activeFilters.push @filterClasses[filter]  if filter of @filterClasses
          i++

        # Get items for active filters with the selected mode
        activeFiltersLength = activeFilters.length
        if mode is "or" or activeFiltersLength is 1

          # Set all items in all active filters active
          i = 0
          while i < activeFiltersLength
            activeItems = activeItems.add(activeFilters[i])
            i++
        else if mode is "and"
          shortestFilter = activeFilters[0]
          itemValid = true
          foundInFilter = undefined
          currentItem = undefined
          currentFilter = undefined

          # Find shortest filter class
          i = 1
          while i < activeFiltersLength
            shortestFilter = activeFilters[i]  if activeFilters[i].length < shortestFilter.length
            i++

          # Iterate over shortest filter and find elements in other filter classes
          shortestFilter = shortestFilter or []
          i = 0
          while i < shortestFilter.length
            currentItem = shortestFilter[i]
            itemValid = true
            j = 0
            while j < activeFilters.length and itemValid
              currentFilter = activeFilters[j]
              if shortestFilter is currentFilter
                j++
                continue

              # Search for current item in each active filter class
              k = 0
              foundInFilter = false

              while k < currentFilter.length and not foundInFilter
                foundInFilter = currentFilter[k] is currentItem
                k++
              itemValid &= foundInFilter
              j++
            activeItems.push shortestFilter[i]  if itemValid
            i++

        # Hide inactive items
        @handler.not(activeItems).addClass "inactive"  unless dryRun
      else

        # Show all items if no filter is selected
        activeItems = @handler

      # Show active items
      unless dryRun
        activeItems.removeClass "inactive"

        # Unset columns and refresh grid for a full layout
        @columns = null
        @layout()
      activeItems


    ###*
    Creates or updates existing placeholders to create columns of even height
    ###
    Wookmark::refreshPlaceholders = (columnWidth, sideOffset) ->
      i = @placeholders.length
      $placeholder = undefined
      $lastColumnItem = undefined
      columnsLength = @columns.length
      column = undefined
      height = undefined
      top = undefined
      innerOffset = undefined
      containerHeight = @container.innerHeight()
      while i < columnsLength
        $placeholder = $("<div class=\"wookmark-placeholder\"/>").appendTo(@container)
        @placeholders.push $placeholder
        i++
      innerOffset = @offset + parseInt(@placeholders[0].css("borderLeftWidth"), 10) * 2
      i = 0
      while i < @placeholders.length
        $placeholder = @placeholders[i]
        column = @columns[i]
        if i >= columnsLength or not column[column.length - 1]
          $placeholder.css "display", "none"
        else
          $lastColumnItem = column[column.length - 1]
          unless $lastColumnItem
            i++
            continue
          top = $lastColumnItem.data("wookmark-top") + $lastColumnItem.data("wookmark-height") + @verticalOffset
          height = containerHeight - top - innerOffset
          $placeholder.css
            position: "absolute"
            display: (if height > 0 then "block" else "none")
            left: i * columnWidth + sideOffset
            top: top
            width: columnWidth - innerOffset
            height: height

        i++
      return


    # Method the get active items which are not disabled and visible
    Wookmark::getActiveItems = ->
      (if @ignoreInactiveItems then @handler.not(".inactive") else @handler)


    # Method to get the standard item width
    Wookmark::getItemWidth = ->
      itemWidth = @itemWidth
      innerWidth = @container.width() - 2 * @outerOffset
      firstElement = @handler.eq(0)
      flexibleWidth = @flexibleWidth
      if @itemWidth is `undefined` or @itemWidth is 0 and not @flexibleWidth
        itemWidth = firstElement.outerWidth()
      else itemWidth = parseFloat(@itemWidth) / 100 * innerWidth  if typeof @itemWidth is "string" and @itemWidth.indexOf("%") >= 0

      # Calculate flexible item width if option is set
      if flexibleWidth
        flexibleWidth = parseFloat(flexibleWidth) / 100 * innerWidth  if typeof flexibleWidth is "string" and flexibleWidth.indexOf("%") >= 0

        # Find highest column count
        paddedInnerWidth = (innerWidth + @offset)
        flexibleColumns = ~~(0.5 + paddedInnerWidth / (flexibleWidth + @offset))
        fixedColumns = ~~(paddedInnerWidth / (itemWidth + @offset))
        columns = Math.max(flexibleColumns, fixedColumns)
        columnWidth = Math.min(flexibleWidth, ~~((innerWidth - (columns - 1) * @offset) / columns))
        itemWidth = Math.max(itemWidth, columnWidth)

        # Stretch items to fill calculated width
        @handler.css "width", itemWidth
      itemWidth


    # Main layout method.
    Wookmark::layout = (force) ->

      # Do nothing if container isn't visible
      return  unless @container.is(":visible")

      # Calculate basic layout parameters.
      columnWidth = @getItemWidth() + @offset
      containerWidth = @container.width()
      innerWidth = containerWidth - 2 * @outerOffset
      columns = ~~((innerWidth + @offset) / columnWidth)
      offset = 0
      maxHeight = 0
      i = 0
      activeItems = @getActiveItems()
      activeItemsLength = activeItems.length
      $item = undefined

      # Cache item height
      if @itemHeightsDirty or not @container.data("itemHeightsInitialized")
        while i < activeItemsLength
          $item = activeItems.eq(i)
          $item.data "wookmark-height", $item.outerHeight()
          i++
        @itemHeightsDirty = false
        @container.data "itemHeightsInitialized", true

      # Use less columns if there are to few items
      columns = Math.max(1, Math.min(columns, activeItemsLength))

      # Calculate the offset based on the alignment of columns to the parent container
      offset = @outerOffset
      offset += ~~(0.5 + (innerWidth - (columns * columnWidth - @offset)) >> 1)  if @align is "center"

      # Get direction for positioning
      @direction = @direction or ((if @align is "right" then "right" else "left"))

      # If container and column count hasn't changed, we can only update the columns.
      if not force and @columns isnt null and @columns.length is columns and @activeItemCount is activeItemsLength
        maxHeight = @layoutColumns(columnWidth, offset)
      else
        maxHeight = @layoutFull(columnWidth, columns, offset)
      @activeItemCount = activeItemsLength

      # Set container height to height of the grid.
      @container.css "height", maxHeight

      # Update placeholders
      @refreshPlaceholders columnWidth, offset  if @fillEmptySpace
      @onLayoutChanged()  if @onLayoutChanged isnt `undefined` and typeof @onLayoutChanged is "function"
      return


    ###*
    Sort elements with configurable comparator
    ###
    Wookmark::sortElements = (elements) ->
      (if typeof (@comparator) is "function" then elements.sort(@comparator) else elements)


    ###*
    Perform a full layout update.
    ###
    Wookmark::layoutFull = (columnWidth, columns, offset) ->
      $item = undefined
      i = 0
      k = 0
      activeItems = $.makeArray(@getActiveItems())
      length = activeItems.length
      shortest = null
      shortestIndex = null
      sideOffset = undefined
      heights = []
      itemBulkCSS = []
      leftAligned = (if @align is "left" then true else false)
      @columns = []

      # Sort elements before layouting
      activeItems = @sortElements(activeItems)

      # Prepare arrays to store height of columns and items.
      while heights.length < columns
        heights.push @outerOffset
        @columns.push []

      # Loop over items.
      while i < length
        $item = $(activeItems[i])

        # Find the shortest column.
        shortest = heights[0]
        shortestIndex = 0
        k = 0
        while k < columns
          if heights[k] < shortest
            shortest = heights[k]
            shortestIndex = k
          k++
        $item.data "wookmark-top", shortest

        # stick to left side if alignment is left and this is the first column
        sideOffset = offset
        sideOffset += shortestIndex * columnWidth  if shortestIndex > 0 or not leftAligned

        # Position the item.
        (itemBulkCSS[i] =
          obj: $item
          css:
            position: "absolute"
            top: shortest
        ).css[@direction] = sideOffset

        # Update column height and store item in shortest column
        heights[shortestIndex] += $item.data("wookmark-height") + @verticalOffset
        @columns[shortestIndex].push $item
        i++
      bulkUpdateCSS itemBulkCSS

      # Return longest column
      Math.max.apply Math, heights


    ###*
    This layout method only updates the vertical position of the
    existing column assignments.
    ###
    Wookmark::layoutColumns = (columnWidth, offset) ->
      heights = []
      itemBulkCSS = []
      i = 0
      k = 0
      j = 0
      currentHeight = undefined
      column = undefined
      $item = undefined
      itemData = undefined
      sideOffset = undefined
      while i < @columns.length
        heights.push @outerOffset
        column = @columns[i]
        sideOffset = i * columnWidth + offset
        currentHeight = heights[i]
        k = 0
        while k < column.length
          $item = column[k].data("wookmark-top", currentHeight)
          (itemBulkCSS[j] =
            obj: $item
            css:
              top: currentHeight
          ).css[@direction] = sideOffset
          currentHeight += $item.data("wookmark-height") + @verticalOffset
          k++
          j++
        heights[i] = currentHeight
        i++
      bulkUpdateCSS itemBulkCSS

      # Return longest column
      Math.max.apply Math, heights


    ###*
    Clear event listeners and time outs and the instance itself
    ###
    Wookmark::clear = ->
      clearTimeout @resizeTimer
      $window.unbind "resize.wookmark", @onResize
      @container.unbind "refreshWookmark", @onRefresh
      @handler.wookmarkInstance = null
      return

    Wookmark
  )()
  $.fn.wookmark = (options) ->

    # Create a wookmark instance if not available
    unless @wookmarkInstance
      @wookmarkInstance = new Wookmark(this, options or {})
    else
      @wookmarkInstance.update options or {}

    # Apply layout
    @wookmarkInstance.layout true
    @show_card_anim = ($card) ->
      randomAnimation = animations[Math.floor(Math.random() * animations.length)]
      console.log(randomAnimation)
      $card.addClass(randomAnimation).show()
      return true

    # Display items (if hidden) and return jQuery object to maintain chainability
    # @show()
    i = 0
    while i < @length
      $card = $(this[i])
      setTimeout (
        @show_card_anim($card)
      ), Math.floor(Math.random() * 10000)
      i++
  return
