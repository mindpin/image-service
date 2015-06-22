class LandingWallpaperChanger
  constructor: ->
    @images = [
      'http://i.teamkn.com/@/i/PoJcRRdp.jpg'
      'http://i.teamkn.com/i/aFe3BSVm.jpg'
      'http://i.teamkn.com/@/i/oCs1Vzo1.jpg'
      'http://i.teamkn.com/@/i/pbaZCcWM.jpg'
      'http://i.teamkn.com/@/i/BhnugkKO.jpg'
      'http://i.teamkn.com/@/i/XmDyCzVO.jpg'
      'http://i.teamkn.com/i/mTn8xIbm.jpg'
      'http://i.teamkn.com/i/j8OavpcU.jpg'
      'http://i.teamkn.com/i/RUIhsP5o.jpg'
      'http://i.teamkn.com/i/dXuyNt55.jpg'
      'http://i.teamkn.com/i/HHxKb43x.jpg'
      'http://i.teamkn.com/i/UtirzpDU.jpg'
      'http://i.teamkn.com/i/lgCGcadA.jpg'
      'http://i.teamkn.com/i/hYyeKSpH.jpg'
      'http://i.teamkn.com/i/afAZUg4G.jpg'
      'http://i.teamkn.com/i/PSUXFyw1.jpg'
      'http://i.teamkn.com/i/k9N26F1a.jpg'
      'http://i.teamkn.com/i/zLZQg4pJ.jpg'
      'http://i.teamkn.com/i/V3N0kJQx.jpg'
      'http://i.teamkn.com/i/lAOmMKbb.jpg'
      'http://i.teamkn.com/@/i/KzNfY7iE.jpg'
    ]

  init: ->
    idx = 0
    @load idx

    jQuery('.img-changer a.prev').on 'click', =>
      idx = idx - 1
      idx = @images.length - 1 if idx < 0
      @load idx

    jQuery('.img-changer a.next').on 'click', =>
      idx = idx + 1
      idx = 0 if idx is @images.length
      @load idx

  load: (idx)->
    img = @images[idx]
    jQuery('<img>').attr('src', img).load ->
      jQuery(this).remove()
      jQuery('.wallpaper').fadeOut ->
        jQuery(this).remove()

      jQuery('<div>')
        .addClass 'wallpaper'
        .css
          'background-image': "url(#{img})"
        .hide()
        .fadeIn()
        .prependTo jQuery(document.body)



class AuthForm
  constructor: (@$elm)->
    @init()

    @bind_toggle_events()
    @bind_sign_in_events()
    @bind_sign_up_events()

  find: (str)->
    @$elm.find(str)

  init: ->
    switch location.hash
      when '#sign-in'
        @find('.sign-in-form').show()
      when '#sign-up'
        @find('.sign-up-form').show()
      else
        @find('.sign-up-form').show()


  bind_toggle_events: ->
    jQuery(@$elm).on 'click', 'a.to.to-sign-in', =>
      @find('.sign-in-form').show()
      @find('.sign-up-form').hide()
      location.hash = 'sign-in'

    jQuery(@$elm).on 'click', 'a.info-to-sign-in', =>
      @find('.sign-in-form').show()
      @find('.sign-up-form').hide()
      location.hash = 'sign-in'
      val = @find('.sign-up-form input.email').val()
      @find('.sign-in-form input.email').val val

    jQuery(@$elm).on 'click', 'a.to.to-sign-up', =>
      @find('.sign-in-form').hide()
      @find('.sign-up-form').show()
      location.hash = 'sign-up'

  bind_sign_in_events: ->
    jQuery(@$elm).on 'click', '.sign-in-form a.sign-in', =>
      @sign_in()

    jQuery(@$elm).on 'keydown', '.sign-in-form input', (evt)=>
      if evt.which is 13
        @sign_in()

  bind_sign_up_events: ->
    jQuery(@$elm).on 'click', '.sign-up-form a.sign-up', =>
      @sign_up()

    jQuery(@$elm).on 'keydown', '.sign-up-form input', (evt)=>
      if evt.which is 13
        @sign_up()

  sign_in: ->
    email = @find('.sign-in-form input.email').val()
    password = @find('.sign-in-form input.pw').val()

    jQuery.ajax
      url: '/sign_in'
      type: 'POST'
      dataType: 'json'
      data:
        user:
          email: email
          password: password
          remember_me: true
      success: (res)->
        location.reload()

      statusCode: {
        401: (res)=>
          console.log res.responseJSON
          @find('.sign-in-form .info').fadeIn()
      }

  sign_up: ->
    username = @find('.sign-up-form input.username').val()
    email = @find('.sign-up-form input.email').val()
    password = @find('.sign-up-form input.pw').val()

    jQuery.ajax
      url: '/'
      type: 'POST'
      dataType: 'json'
      data:
        user:
          name: username
          email: email
          password: password
      success: (res)->
        # 注册成功，转到首页
        location.href = '/'

      statusCode: {
        422: (res)=>
          errors = res.responseJSON
          console.log errors
          $info = @find('.sign-up-form .info').html('').fadeIn()
          for err in errors
            $span = jQuery('<span>').text(err).appendTo $info
            if err.indexOf('注册过了') >= 0
              console.log 111112
              jQuery('<a>')
                .text '登录'
                .addClass('info-to-sign-in')
                .attr('href', 'javascript:;')
                .appendTo $span 
      }


jQuery(document).on 'ready page:load', ->
  if jQuery('.page-landing').length
    new LandingWallpaperChanger().init()
    new AuthForm jQuery('.auth-form')