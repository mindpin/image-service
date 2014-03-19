jQuery ->
  $images = jQuery(".image-show .image")

  $images.on "mouseenter", ->
    jQuery(this).find("input").show()

  $images.on "mouseleave", ->
    jQuery(this).find("input").hide()
