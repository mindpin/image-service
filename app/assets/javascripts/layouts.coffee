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
    @data = {}
    @layout_version = 0
    @compute_data()

  compute_data: ->
    ###
      性能改进策略：
      如果显示区域宽度不变，那么
        网格边长 side_length
        网格列信息 cols
      都不会变化，无需重新计算。
      相应地，如果调用重新布局方法时，以上数据未变化，则不对已经放置好位置的布局对象进行处理
    ###
    width = @host.get_width()
    return if width is @data.container_width

    cols_count = ~~(width / 200)
    pos_data = Util.spacing_grid_data width, cols_count, @GRID_SPACING
    
    @data =
      container_width: width
      side_length: pos_data.side_length
      cols: Util.array_init cols_count, (idx)=>
        left: pos_data.positions[idx]
        height: @GRID_SPACING
    @layout_version += 1

  relayout: (force = false)->
    if force
      @data = {}
      @layout_version += 1
    
    @compute_data()

    cols = @data.cols
    slen = @data.side_length
    @host.each_image (idx, image)=>
      return if image.layout_version is @layout_version
      image.layout_version = @layout_version

      heights = cols.map (col)-> col.height
      top = Util.array_min heights
      x = heights.indexOf top
      left = cols[x].left
      cols[x].height += slen + @GRID_SPACING

      image.pos left, top, slen, slen
      image.lazy_load()

    max_height = Util.array_max cols.map (col)-> col.height
    @host.$el.css 'height', max_height + @BOTTOM_MARGIN

  # 计算是否满足加载更多图片的条件
  need_load_more: ->
    @host.$el.offset_of_window().bottom > - @BOTTOM_MARGIN