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
      @close_opened()

    @$elm.on 'click', '.inputer.saved', (evt)->
      jQuery(this).addClass 'open'

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
        .data
          'x': x
          'y': y
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
        .append jQuery('<span class="t">余</span><span class="c">140</span><span>字</span>')
        .appendTo $control

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

    # success
    $comment = @find('.comment-template').clone()
      .removeClass('comment-template')
      .addClass('comment')
      .find('.user').text(@user_data.char).end()
      .find('.name').text(@user_data.name).end()
      .find('.text').text(text).end()
      .fadeIn(200)
      .appendTo @find('.sidebar .comments')

    @$current_inputer.addClass('saved open')
    @$current_inputer.find('textarea').attr('readonly', true)
    @cached_text = ''
    @is_on_input = false


jQuery(document).on 'ready page:load', ->
  FastClick.attach document.body

  new ImageWhiteBoard jQuery('.page-image-white-board')