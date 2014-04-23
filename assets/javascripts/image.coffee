jQuery ->
  $images = jQuery(".image-show .image")

  $images.on "mouseenter", ->
    jQuery(this).find("input").show().select()

  $images.on "mouseleave", ->
    jQuery(this).find("input").hide()
