window.str_to_color = (str)->
  # a = parseInt '0x' + md5(str)[0...6]
  # s = (a & 0x7f7f7f).toString(16)
  # s = "0#{s}" if s.length is 5
  # "##{s}"
  digest = md5(str)
  rgb = for s in digest[0...3]
    c = (parseInt(s, 16) / 16 + 0.618033988749895) % 1
    i = parseInt(c * 255 + 0.5 - 0.0000005)
    i = i.toString(16)
    i = "0#{i}" if i.length is 1
    i
  "##{rgb.join('')}"


class MessageAdapter
  # iwb means image white board
  constructor: (@iwb)->
    @CHANNEL = "/img4ye-wb-#{@iwb.image_data.id}"
    @client = new Faye.Client('http://faye.4ye.me:9527/faye')

    @client.subscribe @CHANNEL, (msg)=>
      console.log '收到消息', msg
      switch msg.type
        when 'comment-created'
          @receive_comment_created msg.data
        when 'comment-deleted'
          @receive_comment_deleted msg.data

  send_comment_created: (data)->
    @client
      .publish @CHANNEL, {
        type: 'comment-created'
        data: data
      }

  receive_comment_created: (data)->
    @iwb.append_sidebar data
    @iwb.append_inputer(data)?.addClass('saved open')

  send_comment_deleted: (data)->
    @client
      .publish @CHANNEL, {
        type: 'comment-deleted'
        data: data
      }

  receive_comment_deleted: (data)->
    @iwb.remove_comment_by_id data.id

class ImageWhiteBoard
  constructor: (@$elm)->
    @$ibox = @find('.ibox')

    @is_on_input = false

    @user_data = @find('.image-container').data('user')
    @image_data = @find('.image-container').data('image')
    @bind_events()

    @$resizer = jQuery('<pre>')
      .addClass 'input-resizer'
      .appendTo @$elm

    @load()

    @message_adapter = new MessageAdapter @

  load: ->
    jQuery.ajax
      url: "/f/#{@image_data.id}/image_comments"
      type: 'GET'
      success: (res)=>
        for data in res
          @append_sidebar data
          @append_inputer(data).addClass('saved')


  find: (str)->
    @$elm.find str

  bind_events: ->
    that = this

    @$elm.on 'mousemove', '.image-container img', (evt)=>
      offx = evt.offsetX || evt.originalEvent.layerX
      offy = evt.offsetY || evt.originalEvent.layerY
      @show_mouse_pos offx, offy

    @$elm.on 'click', '.image-container img', (evt)=>
      offx = evt.offsetX || evt.originalEvent.layerX
      offy = evt.offsetY || evt.originalEvent.layerY
      if not @find('.inputer.saved.open').length
        @pop_inputer offx, offy

    @$elm.on 'click', (evt)=>
      return if jQuery(evt.target).closest('.inputer').length
      @close_opened()
      @close_inputer()

    @$elm.on 'click', '.inputer.saved', (evt)->
      that.close_opened()
      that.close_inputer()
      jQuery(this).addClass 'open'

    @$elm.on 'click', '.inputer a.delete', (evt)->
      id = jQuery(this).closest('.inputer').data('id')
      that.delete id

  show_mouse_pos: (x, y)->
    @find('.mouse-pos .x').text x
    @find('.mouse-pos .y').text y

  # 弹出输入泡泡
  pop_inputer: (x, y)->
    return if @is_on_input

    setTimeout =>
      @is_on_input = true
      @$current_inputer = @append_inputer {
        x: x
        y: y
        text: @cached_text
        user:
          id: @user_data.id
          name: @user_data.name
      }

      @on_input()

    , 1

  close_inputer: ->
    return if not @is_on_input
    @is_on_input = false
    @cached_text = @$current_inputer?.find('textarea').val()

    @$current_inputer?.fadeOut 200, =>
      @$current_inputer?.remove()

  close_opened: ->
    @find('.inputer.saved.open').removeClass 'open'

  on_input: ()->
    $textarea = @$current_inputer.find 'textarea'

    val = $textarea.val()
    @$resizer.html val + "\n"
    $textarea.css
      'width': @$resizer.width()
      'height': @$resizer.height()

    count = val.length
    limit = 140 - count

    if limit >= 0
      @$current_inputer.find('.limit .t').text '余'
      @$current_inputer.find('.limit .c').text(limit).removeClass('chao')
    else
      @$current_inputer.find('.limit .t').text '超'
      @$current_inputer.find('.limit .c').text(-limit).addClass('chao')

    if count is 0 or limit < 0
      @$current_inputer.find('.control').removeClass('show')
    else
      @$current_inputer.find('.control').addClass('show')

  save: ->
    text = @$current_inputer.find('textarea').val()
    x = @$current_inputer.data('x')
    y = @$current_inputer.data('y')
    console.debug 'save:', x, y, text

    jQuery.ajax
      url: "/f/#{@image_data.id}/image_comments"
      type: 'POST'
      data:
        x: x
        y: y
        text: text
      success: (res)=> 
        @append_sidebar(res)

        @$current_inputer
          .addClass('saved open')
          .attr 'data-id', res.id
          .find('textarea').attr('readonly', true)
        @cached_text = ''
        @is_on_input = false

        @message_adapter.send_comment_created res

  delete: (id)->
    jQuery.ajax
      url: "/f/#{@image_data.id}/image_comments/#{id}"
      type: 'DELETE'
      success: (res)=>
        @remove_comment_by_id id
        @message_adapter.send_comment_deleted {id: id}

  remove_comment_by_id: (id)->
    @find(".inputer[data-id=#{id}]").fadeOut 200, ->
      jQuery(this).remove()
    @find(".comments .comment[data-id=#{id}]").fadeOut 200, ->
      jQuery(this).remove()

  append_sidebar: (comment_data)->
    id = comment_data.id
    user_name = comment_data.user.name
    text = comment_data.text

    return if @find(".comment[data-id=#{id}]").length

    $comment = @find('.comment-template').clone()
      .removeClass('comment-template')
      .addClass('comment')
      .find('.user')
        .text(user_name[0])
        .css
          'background-color': str_to_color user_name
      .end()
      .find('.name').text(user_name).end()
      .find('.text').text(text).end()
      .attr 'data-id', id
      .fadeIn(200)
      .appendTo @find('.sidebar .comments')

  append_inputer: (comment_data)->
    x = comment_data.x
    y = comment_data.y
    id = comment_data.id
    text = comment_data.text
    name = comment_data.user.name
    char = name[0]

    return if @find(".inputer[data-id=#{id}]").length

    is_me = comment_data.user.id is @user_data.id
    console.log is_me

    $inputer = jQuery('<div>')
      .addClass('inputer')
      .appendTo @$ibox
      .data
        'x': x
        'y': y
      .attr
        'data-id': id
      .css
        'left': x
        'top': y
      .hide()
      .fadeIn(200)

    $pop = jQuery('<div>')
      .addClass 'pop'
      .appendTo $inputer

    $user = jQuery('<div>')
      .addClass 'user'
      .appendTo $inputer
      .text char
      .css
        'background-color': str_to_color name

    if is_me
      $delete = jQuery('<a>')
        .addClass('delete')
        .text '删除'
        .attr 'href', 'javascript:;'
        .appendTo $pop

    $textarea = jQuery('<textarea>')
      .attr 'placeholder', '输入评论…'
      .appendTo $pop
      .val text
      .on 'focus', ->
        $inputer.addClass('focus')
      .on 'input', =>
        @on_input $textarea

    $control = jQuery('<div>')
      .addClass 'control'
      .appendTo $pop

    $btn_ok = jQuery('<a>')
      .attr 'href', 'javascript:;'
      .addClass 'b btn-ok'
      .text '保存'
      .appendTo $control
      .on 'click', =>
        @save()

    $btn_cancel = jQuery('<a>')
      .attr 'href', 'javascript:;'
      .addClass 'b btn-cancel'
      .text '取消'
      .appendTo $control
      .on 'click', =>
        @close_inputer()

    $limit = jQuery('<div>')
      .addClass 'limit'
      .append jQuery('<span class="t">余</span><span class="c">140</span><span>字</span>')
      .appendTo $control

    return $inputer 


jQuery(document).on 'ready page:load', ->
  FastClick.attach document.body

  new ImageWhiteBoard jQuery('.page-image-white-board')