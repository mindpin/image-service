window.PresetPopboxAdapter = class PresetPopboxAdapter
  constructor: (@popbox)->

  on_show: ($inner)->
    @$inner = $inner

    # 读取已有配置
    @load_presets()

    # 默认选中第一个
    @find('input').first().attr 'checked', true

    # 设置选中 radio 事件
    @bind_radio_events()

    # 设置限制输入
    @limit_input_number()

    # 注册增加事件
    @bind_add_event()

    # 注册删除事件
    @bind_delete_event()
    

  find: (str)->
    @$inner.find(str)

  load_presets: ->
    jQuery.ajax
      url: ' /image_sizes'
      type: 'GET'
      success: (res)=>
        if res.length is 0
          @find('.records').addClass('blank')
        for preset in res
          @append_preset_dom preset


  append_preset_dom: (preset)->
    @find('.records').removeClass('blank')
    $preset = @find('.preset-template').clone()
      .removeClass('preset-template')
      .addClass('preset')
      .attr('data-id', preset.id)
      .show()
      .find('.desc').text(preset.name).end()
      .appendTo @find('.records .list')
    @refresh_nano()
    return $preset

  refresh_nano: ->
    @find('.rbox.nano')
      .nanoScroller()
      .nanoScroller {
        alwaysVisible: true
        scroll: 'bottom'
      }

    # 刷新页面配置数显示
    jQuery('.stat .c.sizes').text @find('.preset').length

  bind_radio_events: ->
    @$inner.on 'change', '.r0 input', =>
      @find('input.h').attr('disabled', false).val('')
      @find('input.w').attr('disabled', false).val('')
      @find('a.add').addClass('disabled')

    @$inner.on 'change', '.r1 input', =>
      @find('input.h').attr('disabled', true).val('auto')
      @find('input.w').attr('disabled', false).val('')
      @find('a.add').addClass('disabled')

    @$inner.on 'change', '.r2 input', =>
      @find('input.h').attr('disabled', false).val('')
      @find('input.w').attr('disabled', true).val('auto')
      @find('a.add').addClass('disabled')

  limit_input_number: ->
    # 参考此帖实现
    # http://stackoverflow.com/questions/469357/html-text-input-allow-only-numeric-input
    that = this
    @$inner
      .on 'keydown', '.inputs input', (evt)->
        key_code = evt.keyCode
        # backspace, delete, tab, escape, enter and .
        if (jQuery.inArray(key_code, [46, 8, 9, 27, 13, 110, 190]) != -1) or
        # ctrl + A
        (key_code is 65 and evt.ctrlKey is true) or
        # ctrl + C
        (key_code is 67 and evt.ctrlKey is true) or
        # ctrl + X
        (key_code is 88 and evt.ctrlKey is true) or
        # home, end, left, right
        (key_code >= 35 and key_code <= 39)
          return

        if ((evt.shiftKey or (key_code < 48 or key_code > 57)) and (key_code < 96 or key_code > 105))
          evt.preventDefault()

      .on 'input', '.inputs input', ->
        val = jQuery(this).val()
        jQuery(this).val(3000) if val > 3000

        val1 = that.find('input.w').val()
        val2 = that.find('input.h').val()

        if (val1 > 0 or val1 is 'auto') and 
        (val2 > 0 or val2 is 'auto')
          that.find('a.add').removeClass('disabled')
        else
          that.find('a.add').addClass('disabled')

  bind_add_event: ->
    that = this
    @$inner.on 'click', 'a.add', ->
      return if jQuery(this).hasClass 'disabled'
      $control = jQuery(this).closest('.control')

      style  = that.find('input:checked').val()
      width  = that.find('input.w').val()
      height = that.find('input.h').val()
      
      data = switch style
        when 'width_height'
          {
            style: style
            width: width
            height: height
          }
        when 'width'
          {
            style: style
            width: width
          }
        when 'height'
          {
            style: style
            height: height
          }

      jQuery.ajax
        url: '/image_sizes'
        type: 'POST'
        data: data
        success: (res)->
          $p = that
            .append_preset_dom(res)
            .hide()
            .fadeIn 300

  bind_delete_event: ->
    that = this
    @$inner.on 'click', '.preset a.delete', ->
      if confirm '确定要删除这个配置吗？'
        $preset = jQuery(this).closest('.preset')
        id = $preset.data('id')
        jQuery.ajax
          url: "/image_sizes/#{id}"
          type: 'DELETE'
          success: ->
            $preset.fadeOut 300, ->
              $preset.remove()
              if that.find('.preset').length is 0
                that.find('.records').addClass('blank')
              that.refresh_nano()