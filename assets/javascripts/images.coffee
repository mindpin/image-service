class Image
  constructor: (@$el)->
    @major_color = @$el.data 'major-color'
    @width       = @$el.data 'width'
    @height      = @$el.data 'height'
    @base_url    = @$el.data 'base'

    @padding = 0

    @$ibox = @$el.find('.ibox')
    @$ibox.css 'background-color', @major_color

  get_png_url: (width, height)->
    "#{@base_url}@#{width}w_#{height}h_1e_1c.png"

  pos: (left, top, width, height)->
    @layout_left = left
    @layout_top = top
    @layout_width = width
    @layout_height = height

    @$el
      .css
        'left': left
        'top': top
        'width': width
        'height': height

  is_in_screen: ->
    return @$el.is_in_screen()

  load: ->
    return if @loaded
    @loaded = true

    w = Math.round @layout_width - @padding * 2
    h = Math.round @layout_height - @padding * 2

    img = jQuery "<img>"
      .attr 'src', @get_png_url(w, h)
      .attr 'draggable', false
      .css 'opacity', 0
      .on 'load', =>
        img.animate
          'opacity': 1
        , 400, =>
          @$ibox.css 'background', 'none'
      .appendTo @$ibox

  set_padding: (padding)->
    @padding = padding
    @$el.css 'box-shadow', '1px 1px 3px rgba(0, 0, 0, 0.4)'
      .find('.ibox')
      .css
        'top': padding
        'left': padding
        'right': padding
        'bottom': padding

# 水平网格布局
class HorizontalGridLayout
  constructor: (@host)->
    @GRIDS = 6
    @GRID_PADDING = 4

    @bind_events()

  go: ->
    # 计算屏幕宽高
    screen_height = jQuery(document).height()
    screen_width  = jQuery(document).width()

    # 计算 grid 边长
    side_length = (screen_height - @GRID_PADDING * (@GRIDS + 1)) / @GRIDS

    that = @
    max_left = 0
    max_top = 0

    @host.each_image (idx, image)->
      x = ~~(idx / that.GRIDS)
      y = idx % that.GRIDS

      left = that.GRID_PADDING + x * (side_length + that.GRID_PADDING)
      top = that.GRID_PADDING + y * (side_length + that.GRID_PADDING)

      image.x = x
      image.y = y
      max_left = 0
      max_top = 0
      image.pos left, top, side_length, side_length

      max_left = Math.max max_left, image.layout_left
      max_top = Math.max max_top, image.layout_top

      image.load() if image.is_in_screen()

    @host.$container
      .css
        'height': '100%'
        'width': max_left + side_length

  bind_events: ->
    # 鼠标滚轮横向滚动
    @host.$el.on 'mousewheel', (evt)=>
      move = 100
      left = parseInt @host.$container.css 'left'
      left -= move if evt.deltaY < 0
      left += move if evt.deltaY > 0
      left = 0 if left > 0

      @host.$container
        .css
          'left': left

      @host.lazy_load_images()

# 瀑布流
class FlowLayout
  constructor: (@host)->
    @GRID_PADDING = 15
    @bind_events()

  go: ->
    @_set_container_style()

    container_width = @host.$container.width()

    GRID_COUNT = ~~(container_width / 200)
    side_length = (container_width - @GRID_PADDING * (GRID_COUNT - 1)) / GRID_COUNT


    cols = ({height: @GRID_PADDING} for i in [0 ... GRID_COUNT])
    padding = 4
    @host.each_image (idx, image)=>
      image.set_padding 4

      heights = cols.map (col)-> col.height
      minh = jQuery.array_min heights
      x = heights.indexOf minh

      left = x * (side_length + @GRID_PADDING)
      top = minh
      height = side_length * image.height / image.width

      cols[x].height += height + @GRID_PADDING

      image.pos left, top, side_length, height
      setTimeout ->
        image.load() if image.is_in_screen()

  _set_container_style: ->
    @host.$container.closest('.page-images')
      .addClass 'col-pad-12'
      .css 
        'position': 'relative'
        'background': 'none'

  bind_events: ->
    # 鼠标滚轮横向滚动
    jQuery(document).on 'scroll', (evt)=>
      @host.lazy_load_images()

# 普通网格
class GridLayout
  constructor: (@host)->
    @GRID_SPACING = 15
    @bind_events()

  go: ->
    @_set_container_style()

    setTimeout =>
      container_width = @host.$container.width()
      GRID_COUNT = ~~(container_width / 200)

      grid_data = Util.spacing_grid_data container_width, GRID_COUNT, @GRID_SPACING

      side_length = grid_data.side_length

      cols = jQuery.array_init GRID_COUNT, => 
        height: @GRID_SPACING

      @host.each_image (idx, image)=>
        heights = cols.map (col)-> col.height
        top = jQuery.array_min heights
        x = heights.indexOf top
        left = grid_data.positions[x]
        cols[x].height += side_length + @GRID_SPACING

        image.pos left, top, side_length, side_length
        setTimeout ->
          image.load() if image.is_in_screen()

      max_height = jQuery.array_max cols.map (col)-> col.height
      @host.$container.css 'height', max_height + 80

  _set_container_style: ->
    @host.$container.closest('.page-images')
      .addClass 'col-pad-12'
      .css 
        'position': 'relative'
        'background': 'none'

  bind_events: ->
    jQuery(document).on 'scroll', (evt)=>
      @host.lazy_load_images()

      # 计算图片区域底部是否进入屏幕
      off_bottom = @host.$container.offset_of_window().bottom
      if off_bottom > -100
        @load_next_page()

  load_next_page: ->
    return if @host.$container.hasClass 'end'
    return if @host.$container.hasClass 'loading'
    @host.$container.addClass 'loading'
    page = @host.$container.data('page') || 1
    jQuery.ajax
      url: @host.list_url
      type: 'GET'
      data:
        page: page + 1
      success: (res)=>
        that = @
        $images = jQuery(res).find('.icontainer .image')

        if $images.length
          $images.each ->
            $image = jQuery(this)
            that.host.$container.append $image
            that.host.add_image $image
          @host.layout()
          @host.$container.removeClass 'loading'
          @host.$container.data 'page', page + 1

        else
          @host.$container.removeClass 'loading'
          @host.$container.addClass 'end'


class ImageGrid
  constructor: (@$el, list_url)->
    # @_layout = new FlowLayout @
    # @_layout = new HorizontalGridLayout @
    @list_url = list_url
    @_layout = new GridLayout @

    @$container = @$el.find('.icontainer')
    
    @images = []
    that = @
    @$container.find('.image').each ->
      that.add_image jQuery(this)

    @bind_events()

  add_image: ($image)->
    @images.push new Image $image

  each_image: (func)->
    for idx in [0 ... @images.length]
      func idx, @images[idx] 

  # 对所有图片重新布局
  layout: ->
    @_layout.go()

  bind_events: ->
    that = this

    # 图片点击
    @$el.delegate '.image', 'click', ->
      # nothing

  lazy_load_images: ->
    @each_image (idx, image)->
      image.load() if image.is_in_screen()


jQuery ->
  if jQuery('.page-images').length
    list_url = '/zmkm/images'
    grid = new ImageGrid jQuery('.page-images'), list_url
    grid.layout()

    jQuery(window).on 'resize', ->
      grid.layout()

  if jQuery('.page-image-show').length
    jQuery(document).delegate 'input.url', 'click', ->
      jQuery(this).select()