# 可能会用到 turbolinks
# turbolinks 事件加载参考
# https://github.com/rails/turbolinks/#no-jquery-or-any-other-library

# 处理七牛图片网址
window.QiniuURLFormater = class QiniuURLFormater 
  @format: (conf)->
    url    = conf.url
    width  = conf.width
    height = conf.height

    switch conf.style
      when 'width_height'
        "#{url}?imageMogr2/thumbnail/!#{width}x#{height}r/gravity/Center/crop/#{width}x#{height}"
      when 'width'
        "#{url}?imageMogr2/thumbnail/#{width}x"
      when 'height'
        "#{url}?imageMogr2/thumbnail/x#{height}"

# 图片加载类
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

    if not @$el.hasClass 'aliyun'
      jQuery('<div>')
        .addClass('icheck')
        .appendTo @$el

    jQuery('<a>')
      .addClass('show-detail')
      .attr 
        'href': "/f/#{@$el.data('id')}"
        'target': '_blank'
      .append jQuery('<i>').addClass('fa fa-image')
      .append jQuery('<span>').text '查看详情'
      .appendTo @$el

  get_png_url: (width, height)->
    if @$el.hasClass 'aliyun'
      return "#{@url}@#{width}w_#{height}h_1e_1c"

    QiniuURLFormater.format {
      url: @url
      width: width
      height: height
      style: 'width_height'
    }

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
    # @$el 对应 .grid .images
    @$viewport = config.viewport || jQuery(document)
    @layout = new (config.layout || GridLayout) @

    @$el.css
      'position': 'relative'
    
    @image_hash = new OrderedHash
    for dom in @$el.find('.image')
      @append_image jQuery(dom)

    @load_more_url = @$el.data('load-more-url')
    @bind_events()

  bind_events: ->
    @$viewport.on 'scroll', (evt)=>
      @lazy_load_images()
      jQuery(document).trigger 'img4ye:try-loadmore'

    @$viewport.on 'mindpin', ->
      alert(1)

  append_image: ($image)->
    img = new Image $image
    @image_hash.append $image.data('id'), img

  prepend_image: ($image)->
    img = new Image $image
    @image_hash.prepend $image.data('id'), img

  remove_img_ids: (ids)->
    for id in ids
      img = @image_hash.get id
      img.remove()
      @image_hash.del id
    @relayout(true)

  each_image: (func)->
    # for idx in [0 ... @images.length]
    #   func idx, @images[idx] 
    idx = 0
    @image_hash.each (id, img)->
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
      jQuery(document).trigger 'img4ye:try-loadmore'

  lazy_load_images: ->
    @image_hash.each (id, img)->
      img.lazy_load()

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
          @append_image $image

        @relayout()
        @$el.removeClass 'loading'
      else
        @$el.removeClass 'loading'
        @$el.addClass 'end'

  refresh_stat: (statdata)->
    jQuery('.control .stat')
      .find('span.c.fcount').text(statdata.image_count).end()
      .find('span.c.space').text(statdata.space_used).end()

    if statdata.image_count is 0
      @$el.addClass('blank')
    else
      @$el.removeClass('blank')



# ----------
# 复选图片

class ImageSelector
  constructor: (@$el)->
    @bind_events()

  bind_events: ->
    that = this
    @$el.on 'click', '.image', ->
      jQuery(this).toggleClass('selected')
      that.refresh_selected()

    jQuery('.checkstatus a.check').on 'click', ->
      $checkstatus = jQuery(this).closest('.checkstatus')
      if $checkstatus.hasClass('none') or $checkstatus.hasClass('some')
        that.$el.find('.image').addClass('selected')
        that.refresh_selected()
        return
      if $checkstatus.hasClass('all')
        that.$el.find('.image').removeClass('selected')
        that.refresh_selected()
        return

    @$el.on 'click', '.image a.show-detail', (evt)->
      evt.stopPropagation()

  refresh_selected: ->
    length = @$el.find('.image.selected').length
    all_length = @$el.find('.image').length
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
    @$el.find('.image.selected').closest('.image')

  get_selected_ids: ->
    jQuery(image).data('id') for image in @get_selected()


jQuery(document).on 'ready page:load', ->
  FastClick.attach document.body

  jQuery('.image-info.nano').nanoScroller {
    alwaysVisible: true
  }

  if jQuery('.grid .images').length
    window.igrid = new ImageGrid jQuery('.grid .images'), {
      # layout: FlowLayout
      layout: GridLayout
      viewport: jQuery('.grid .nano-content')
    }

    igrid.relayout()

    jQuery(window)
      .off 'resize'
      .on 'resize', ->
        igrid.lazy_load_images()
        igrid.relayout()

    ise = new ImageSelector jQuery('.grid .images')

    # 删除对话框
    popbox_delete = new PopBox jQuery('.popbox.template.delete')
    jQuery('.opbar a.bttn.delete').on 'click', ->
      new DeletePopboxAdapter(popbox_delete, ise)

    # 尺寸配置对话框
    popbox_presets = new PopBox jQuery('.popbox.template.presets'), { box_width: '660px' }
    jQuery('.stat a.preset-config').on 'click', ->
      new PresetPopboxAdapter(popbox_presets)

    # 下载对话框
    window.popbox_download = new PopBox jQuery('.popbox.template.download')
    jQuery('.opbar a.bttn.download').on 'click', ->
      new DownloadPopboxAdapter(popbox_download, ise)

    # 获取链接对话框
    popbox_links = new PopBox jQuery('.popbox.template.links'), { box_width: '860px' }
    jQuery('.opbar .bttn.copylink').on 'click', ->
      new LinksPopboxAdapter(popbox_links, ise)

    # 上传面板中的链接表单
    window.upload_links_form = new LinksForm jQuery('.upload-panel .linksform'), ->
      urls = []
      jQuery('.uploading-images .image.done').each ->
        urls.push jQuery(this).data('url')
      urls


jQuery(document).on 'click', '.preset .field input', ->
  jQuery(this).select()

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

jQuery(document).on 'img4ye:try-loadmore', ->
  if igrid = window.igrid
    igrid.load_more() if igrid.layout.need_load_more()

jQuery(document).on 'img4ye:file-changed', (evt, statdata)->
  window.igrid?.refresh_stat statdata

jQuery(document).on 'img4ye:file-uploaded', (evt, info)->
  if igrid = window.igrid
    $image = jQuery('<div>')
      .addClass('image')
      .attr
        'data-ave': info.ave
        'data-width': info.width
        'data-height': info.height
        'data-url': info.url
        'data-id': info.id

    igrid.$el.prepend $image
    igrid.prepend_image $image
    igrid.relayout(true)