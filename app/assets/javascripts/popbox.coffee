window.PopBox = class PopBox
  constructor: (@$template, conf = {})->
    @box_width = conf.box_width

  show: (func)->
    @is_show = true

    @$overlay = jQuery('<div>')
      .addClass 'popbox popbox-overlay'
      .fadeIn(300)
      .appendTo jQuery(document.body)

    @$overlay.on 'click', (evt)=>
      if jQuery(evt.target).hasClass 'popbox-overlay'
        @close()

    @$overlay.on 'click', '.popbox a.popbox.action.close', (evt)=>
      @close()

    @$box = jQuery('<div>')
      .addClass 'popbox box'
      .css
        'top': '0'
        'width': @box_width
      .animate
        'top': '180px'
      , 200
      .appendTo @$overlay

    @$inner = @$template.clone().show()
      .appendTo @$box

    func()

  new_instance: (func)->
    @show =>
      func @$inner

  run_adapter: (adapter)->
    @new_instance ($inner)->
      adapter.on_show $inner

  close: ->
    @is_show = false

    @$box.animate
      'top': '0'
    , 200
    @$overlay.fadeOut 300, =>
      @$overlay.remove()

  bind_ok: (func)->
    @$overlay.on 'click', '.popbox a.popbox.action.ok', func