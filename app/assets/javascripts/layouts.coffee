# 水平网格布局
window.HorizontalGridLayout = class HorizontalGridLayout
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
window.FlowLayout = class FlowLayout
  GRID_SPACING: 15

  constructor: (@host)->

  render: ->
    setTimeout =>
      container_width = @host.get_width()
      columns_count = ~~(container_width / 180)
      grid_data = Util.spacing_grid_data container_width, columns_count, @GRID_SPACING
      side_length = grid_data.side_length
      cols = Util.array_init columns_count, => 
        height: @GRID_SPACING

      @host.each_image (idx, image)=>
        heights = cols.map (col)-> col.height
        top = Util.array_min heights
        x = heights.indexOf top
        left = grid_data.positions[x]
        height = side_length * image.height / image.width
        cols[x].height += height + @GRID_SPACING

        image.pos left, top, side_length, height
        image.lazy_load()

      max_height = Util.array_max cols.map (col)-> col.height
      @host.$el.css 'height', max_height + @BOTTOM_MARGIN

  # 计算是否满足加载更多图片的条件
  need_load_more: ->
    @host.$el.offset_of_window().bottom > - @BOTTOM_MARGIN


# 普通网格
window.GridLayout = class GridLayout
  GRID_SPACING: 15
  BOTTOM_MARGIN: 80

  constructor: (@host)->

  render: ->
    container_width = @host.get_width()
    columns_count = ~~(container_width / 200)
    grid_data = Util.spacing_grid_data container_width, columns_count, @GRID_SPACING
    side_length = grid_data.side_length
    cols = Util.array_init columns_count, => 
      height: @GRID_SPACING

    @host.each_image (idx, image)=>
      heights = cols.map (col)-> col.height
      top = Util.array_min heights
      x = heights.indexOf top
      left = grid_data.positions[x]
      cols[x].height += side_length + @GRID_SPACING

      image.pos left, top, side_length, side_length
      setTimeout ->
        image.lazy_load()
      , 100

    max_height = Util.array_max cols.map (col)-> col.height
    @host.$el.css 'height', max_height + @BOTTOM_MARGIN

  # 计算是否满足加载更多图片的条件
  need_load_more: ->
    @host.$el.offset_of_window().bottom > - @BOTTOM_MARGIN