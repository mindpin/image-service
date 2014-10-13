class ImageGrid
  constructor: (@$el)->
    @GRIDS = 4

    @GRID_PADDING = 4
    @$images = @$el.find('.images')
    
    @bind_events()

  each_image: (func)->
    @$images.find('.image').each ->
      func jQuery(this)


  # 对所有图片重新布局
  layout: ->
    return if @$images.hasClass 'show-detail'

    # 计算屏幕高度
    screen_height = jQuery(document).height()

    # 计算 grid 边长
    grid_w = (screen_height - @GRID_PADDING * (@GRIDS + 1)) / @GRIDS

    that = @
    max_left = 0
    @$images.find('.image').each (idx)->
      x = ~~(idx / that.GRIDS)
      y = idx % that.GRIDS

      left = that.GRID_PADDING + x * (grid_w + that.GRID_PADDING)
      top = that.GRID_PADDING + y * (grid_w + that.GRID_PADDING)

      $image = jQuery(this)
      $image
        .data
          'x': x
          'y': y
        .css
          'left': left
          'top': top
          'width': grid_w
          'height': grid_w
          'background-color': $image.data('major-color')

      max_left = left if left > max_left

    @$images
      .css
        'height': '100%'
        'width': max_left + grid_w


    @load_images()


  bind_events: ->
    that = this

    @$el.on 'mousewheel', (evt)=>
      move = 100
      left = parseInt @$images.css 'left'

      left -= move if evt.deltaY < 0
      left += move if evt.deltaY > 0

      left = 0 if left > 0

      @$images
        .css
          'left': left

      @load_images()


    @$el.delegate '.image', 'click', ->
      $image = jQuery(this)
      that.show_detail $image


  load_images: ->
    that = this
    @each_image ($image)=>
      if @_is_in_screen $image
        @_load $image


  _is_in_screen: ($image)->
    offset_left = $image.offset().left
    offset_right = offset_left + $image.width()

    screen_width = jQuery(document).width()

    return false if offset_right < 0
    return false if offset_left > screen_width
    return true


  _load: ($image)->
    return if $image.hasClass '--loaded'

    $image.addClass '--loaded'
    img = jQuery "<img src='#{$image.data('src')}' />"
      .addClass 'loading'
      .on 'load', ->
        img.removeClass 'loading'
      .appendTo $image


  # 显示单个图片详情
  show_detail: ($image)->
    @$images.addClass 'show-detail'

    w = jQuery(document).height() - @GRID_PADDING * 2
    src = $image.data('base') + "@#{w}w_#{w}h_1e_1c"

    $image
      .addClass 'show-detail'
      .css
        'top': @GRID_PADDING
        'left': @GRID_PADDING
        'height': w
        'width': w
      .find('img').attr 'src', src


jQuery ->
  if jQuery('.page-images').length
    grid = new ImageGrid jQuery('.page-images')
    grid.layout()

    jQuery(window).on 'resize', ->
      grid.layout()