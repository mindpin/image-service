class ImageWhiteBoard
  constructor: (@$elm)->
    @$ibox = @find('.ibox')

    @is_on_input = false

    @user_data = @find('.image-container').data('user')
    @bind_events()

    @$resizer = jQuery('<pre>')
      .addClass 'input-resizer'
      .appendTo @$elm

  find: (str)->
    @$elm.find str

  bind_events: ->
    that = this

    @$elm.on 'mousemove', '.image-container img', (evt)=>
      offx = evt.offsetX
      offy = evt.offsetY
      @show_mouse_pos offx, offy

    @$elm.on 'click', '.image-container img', (evt)=>
      offx = evt.offsetX
      offy = evt.offsetY
      @pop_inputer offx, offy

    @$elm.on 'click', (evt)=>
      return if jQuery(evt.target).closest('.inputer').length
      @close_inputer()

  show_mouse_pos: (x, y)->
    @find('.mouse-pos .x').text x
    @find('.mouse-pos .y').text y

  # 弹出输入泡泡
  pop_inputer: (x, y)->
    return if @is_on_input

    setTimeout =>
      @is_on_input = true

      @$current_inputer = $inputer = jQuery('<div>')
        .addClass('inputer')
        .appendTo @$ibox
        .css
          'left': x
          'top': y
        .hide()
        .fadeIn(200)

      $user = jQuery('<div>')
        .addClass 'user'
        .appendTo $inputer
        .text @user_data.char

      $pop = jQuery('<div>')
        .addClass 'pop'
        .appendTo $inputer

      $textarea = jQuery('<textarea>')
        .attr 'placeholder', '输入评论…'
        .appendTo $pop
        .val @cached_text
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
        .append jQuery('<span>余</span><span class="c">140</span><span>字</span>')
        .appendTo $control

    , 1

  close_inputer: ->
    return if not @is_on_input
    @is_on_input = false
    @cached_text = @$current_inputer?.find('textarea').val()

    @$current_inputer?.fadeOut 200, =>
      @$current_inputer?.remove()

  on_input: ($textarea)->
    val = $textarea.val()
    @$resizer.html val + "\n"
    $textarea.css
      'width': @$resizer.width()
      'height': @$resizer.height()

    count = val.length
    limit = 140 - count
    @find('.limit .c').text limit

  save: ->
    console.debug '1'
    # jQuery.ajax
    #   url: 'http://key-value.4ye.me/write'
    #   type: 'POST'
    #   data:
    #     token: @user_data.id
    #     scope: 'img4ye-whiteboard'
    #     key: 'data'
    #     value: 'aaa'
    #   success: (res)->
    #     console.log res


jQuery(document).on 'ready page:load', ->
  FastClick.attach document.body

  new ImageWhiteBoard jQuery('.page-image-white-board')