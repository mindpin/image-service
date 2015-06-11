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
    "#{@url}?imageView2/1/w/#{width}/h/#{height}"

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

    return if not (@layout_width? and @layout_height?)

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

  remove: ->
    @$el.remove()

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
    ig.relayout()
###
class ImageGrid
  constructor: (@$el, config = {})->
    @$viewport = config.viewport || jQuery(document)
    @layout = new (config.layout || GridLayout) @

    @$el.css
      'position': 'relative'
    
    @image_hash = {}
    for dom in @$el.find('.image')
      @add_image jQuery(dom)

    @load_more_url = @$el.data('load-more-url')
    @bind_events()

  bind_events: ->
    @$viewport.on 'scroll', (evt)=>
      @lazy_load_images()
      @load_more() if @layout.need_load_more()

    @$viewport.on 'mindpin', ->
      alert(1)

  add_image: ($image)->
    img = new Image $image
    jQuery('<div>')
      .addClass('icheck')
      .appendTo img.$el
    @image_hash[$image.data('id')] = img

  remove_img_ids: (ids)->
    for id in ids
      img = @image_hash[id]
      img.remove()
      delete @image_hash[id]
    @relayout(true)
    @load_more() if @layout.need_load_more()

  each_image: (func)->
    # for idx in [0 ... @images.length]
    #   func idx, @images[idx] 
    idx = 0
    for id, img of @image_hash
      func idx, img
      idx++

  # 对所有图片重新布局
  relayout: (force = false)->
    @layout.relayout(force)
    setTimeout ->
      jQuery('.grid.nano').nanoScroller {
        alwaysVisible: true
        # flash: true
      }

  lazy_load_images: ->
    image.lazy_load() for id, image of @image_hash

  get_width: ->
    @$el.width()

  load_more: ->
    return if @$el.hasClass('end') or @$el.hasClass('loading')
    @$el.addClass 'loading'
    
    less_than_id = jQuery('.grid .images .image').last().data('id')

    jQuery.get @load_more_url, { 
      less_than_id: less_than_id 
    }
    .done (res)=>
      $images = jQuery(res).find('.grid .images .image')

      if $images.length
        $images.each (idx, el)=>
          $image = jQuery(el)
          @$el.append $image
          @add_image $image

        @relayout()
        @$el.removeClass 'loading'
      else
        @$el.removeClass 'loading'
        @$el.addClass 'end'



# ----------
# 复选图片

class ImageSelector
  constructor: (@$el)->
    @bind_events()

  bind_events: ->
    that = this
    @$el.on 'click', '.image .icheck', ->
      jQuery(this).toggleClass('selected')
      that.refresh_selected()

    jQuery('.checkstatus a.check').on 'click', ->
      $checkstatus = jQuery(this).closest('.checkstatus')
      if $checkstatus.hasClass('none') or $checkstatus.hasClass('some')
        that.$el.find('.image .icheck').addClass('selected')
        that.refresh_selected()
        return
      if $checkstatus.hasClass('all')
        that.$el.find('.image .icheck').removeClass('selected')
        that.refresh_selected()
        return

  refresh_selected: ->
    length = @$el.find('.image .icheck.selected').length
    all_length = @$el.find('.image .icheck').length
    jQuery('.opbar .checkstatus span.n').text length
    jQuery('.opbar .checkstatus').removeClass('none some all')
    if length is 0
      jQuery('.opbar .checkstatus').addClass('none')
    else if length < all_length
      jQuery('.opbar .checkstatus').addClass('some')
    else
      jQuery('.opbar .checkstatus').addClass('all')

    if length > 0
      jQuery('.opbar .btns .bttn').removeClass('disabled')
    else
      jQuery('.opbar .btns .bttn').addClass('disabled')

  get_selected: ->
    @$el.find('.image .icheck.selected').closest('.image')


jQuery(document).on 'ready page:load', ->
  if jQuery('.grid .images').length
    igird = new ImageGrid jQuery('.grid .images'), {
      # layout: FlowLayout
      layout: GridLayout
      viewport: jQuery('.grid .nano-content')
    }

    igird.relayout()

    jQuery(window)
      .off 'resize'
      .on 'resize', -> 
        igird.relayout()

    ise = new ImageSelector jQuery('.grid .images')

    popbox_delete = new PopBox jQuery('.popbox.template.delete')
    jQuery('.opbar a.bttn.delete').on 'click', ->
      popbox_delete.show ->
        len = ise.get_selected().length
        popbox_delete.$inner.find('span.n').text len
        popbox_delete.bind_ok ->
          ids = for image in ise.get_selected()
            jQuery(image).data('id')
          jQuery.ajax
            url: '/file_entities/batch_delete'
            type: 'DELETE'
            data: 
              ids: ids.join(',')
            success: (res)->
              igird.remove_img_ids ids
              popbox_delete.close()
              ise.refresh_selected()

    popbox_download = new PopBox jQuery('.popbox.template.download')
    jQuery('.opbar a.bttn.download').on 'click', ->
      popbox_download.show ->
        len = ise.get_selected().length
        popbox_download.$inner.find('span.n').text len
        ids = for image in ise.get_selected()
          jQuery(image).data('id')

        # 发起打包请求
        popbox_download.$inner
          .removeClass 'error success dabao'
          .addClass 'dabao'
        jQuery.ajax
          url: '/file_entities/create_zip'
          type: 'POST'
          data:
            ids: ids.join(',')
          success: (res)->
            $elm = popbox_download.$inner
            $elm.find('.wait').html ''
            test_dabao $elm, res.task_id

test_dabao = ($elm, task_id)->
  jQuery.ajax
    url: '/file_entities/get_create_zip_task_state'
    type: 'GET'
    data:
      task_id: task_id
    success: (res)->
      console.log res
      if res.state is 'processing'
        if $elm.find('.wait span').length > 32
          $elm.find('.wait').html ''
        $elm.find('.wait').append jQuery('<span>.</span>')
        test_dabao $elm, task_id

        setTimeout ->
          test_dabao $elm, task_id
        , 200
        
      if res.state is 'success'
        $elm
          .removeClass 'error success dabao'
          .addClass 'success'

        $elm.find('a.download-zip').attr('href', res.url)

      if res.state is 'failure'
        $elm
          .removeClass 'error success dabao'
          .addClass 'error'



# jQuery(document).on 'click', 'textarea.urls', ->
#   jQuery(this).select()

jQuery(document).on 'click', 'a.close-panel', ->
  $panel = jQuery('.upload-panel')
  $panel.removeClass('opened')
  # 这里先临时放一些视觉效果，集成时要修改
  jQuery('.uploading-images .image').addClass('done')
  jQuery('.uploading-images .image .bar').stop()
    .css
      'width': '100%'
  jQuery('.uploading-images .image .txt .p').text('0')
  jQuery('textarea.urls').val ''

jQuery(document).on 'click', '.uploading-images .image .cancel', ->
  $image = jQuery(this).closest('.image')
  $image.hide 300, ->
    $image.remove()
    demo_progress()
  jQuery('.uploading-images .image .bar').stop()