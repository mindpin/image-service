class LandingWallpaperChanger
  constructor: ->
    @images = [
      'http://i.teamkn.com/@/i/KzNfY7iE.jpg'
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


jQuery(document).on 'ready page:load', ->
  if jQuery('.page-landing').length
    new LandingWallpaperChanger().init()