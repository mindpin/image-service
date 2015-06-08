# 可能会用到 turbolinks
# turbolinks 事件加载参考
# https://github.com/rails/turbolinks/#no-jquery-or-any-other-library

###
  图片加载类
###
class Image
  constructor: (@$el)->
    @ave    = @$el.data 'ave' # 平均色值
    @width  = @$el.data 'width' # 原始宽
    @height = @$el.data 'height' # 原始高
    @url    = @$el.data 'url' # 原始地址

    @$el.css
      'position': 'absolute'

    @$ibox = jQuery('<div>')
      .addClass 'ibox'
      .css 
        'background-color': @ave
        'position': 'absolute'
        'top': 0
        'left': 0
        'right': 0
        'bottom': 0
      .appendTo @$el

  get_png_url: (width, height)->
    "#{@url}@#{width}w_#{height}h_1e_1c.png"

  pos: (left, top, width, height)->
    @$el.css
      'left'   : @layout_left = left
      'top'    : @layout_top = top
      'width'  : @layout_width = width
      'height' : @layout_height = height

  lazy_load: ->
    return if not @$el.is_in_screen()
    @load()

  load: ->
    return if @loaded
    @loaded = true

    w = Math.round @layout_width
    h = Math.round @layout_height

    img = jQuery "<img>"
      .attr 'src', @get_png_url(w, h)
      .attr 'draggable', false
      .css
        'opacity': 0
        'width': '100%'
        'height': '100%'
      .on 'load', =>
        img.animate
          'opacity': 1
        , 400, =>
          @$ibox.css 'background', 'none'
      .appendTo @$ibox

###
用途：
  图像网格，支持以多种布局来显示图像
  同时支持滚动加载更多图片
用法：
  haml:
    .grid
      .images
        .image{:data => {:url => '', :width => '', :height => '', :ave => ''}}
        .image{:data => {:url => '', :width => '', :height => '', :ave => ''}}
        .image{:data => {:url => '', :width => '', :height => '', :ave => ''}}

  coffee:
    ig = new ImageGrid jQuery('.images'), {
      layout: GridLayout
      viewport: jQuery('.grid')
    }
    ig.render()
###
class ImageGrid
  constructor: (@$el, config = {})->
    @$viewport = config.viewport || jQuery(document)
    @layout = new (config.layout || GridLayout) @

    @$el.css
      'position': 'relative'
    
    @images = []
    for dom in @$el.find('.image')
      @add_image jQuery(dom)

    @load_more_url = @$el.data('load-more-url')
    @bind_events()

  bind_events: ->
    @$viewport.on 'scroll', (evt)=>
      @lazy_load_images()
      @load_more() if @layout.need_load_more()

  add_image: ($image)->
    img = new Image $image
    jQuery('<div>')
      .addClass('icheck')
      .appendTo img.$el
    @images.push img

  each_image: (func)->
    for idx in [0 ... @images.length]
      func idx, @images[idx] 

  # 对所有图片重新布局
  render: ->
    @layout.render()
    setTimeout ->
      jQuery('.nano').nanoScroller {
        alwaysVisible: true
        # flash: true
      }

  lazy_load_images: ->
    image.lazy_load() for image in @images

  get_width: ->
    @$el.width()

  load_more: ->
    return if @$el.hasClass 'end'
    return if @$el.hasClass 'loading'
    @$el.addClass 'loading'
    page = @$el.data('page') || 1
    jQuery.ajax
      url: @load_more_url
      type: 'GET'
      data:
        page: page + 1
      success: (res)=>
        $images = jQuery(res).find('.grid .images .image')

        if $images.length
          $images.each (idx, el)=>
            $image = jQuery(el)
            @$el.append $image
            @add_image $image

          @render()
          @$el.removeClass 'loading'
          @$el.data 'page', page + 1

        else
          @$el.removeClass 'loading'
          @$el.addClass 'end'


jQuery(document).on 'ready page:load', ->
  if jQuery('.grid .images').length
    ig = new ImageGrid jQuery('.grid .images'), {
      # layout: FlowLayout
      layout: GridLayout
      viewport: jQuery('.grid .nano-content')
    }

    ig.render()

    jQuery(window)
      .off 'resize'
      .on 'resize', -> 
        ig.render()

  # if jQuery('.page-image-show').length
  #   jQuery(document).delegate 'input.url', 'click', ->
  #     jQuery(this).select()

jQuery(document).on 'click', 'a.btn-upload', ->
  $panel = jQuery('.upload-panel')
  $panel.addClass('opened')

jQuery(document).on 'click', 'a.close-panel', ->
  $panel = jQuery('.upload-panel')
  $panel.removeClass('opened')