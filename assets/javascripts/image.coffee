jQuery ->
  $images = jQuery(".image-show .image")

  $images.find("input").on "click", ->
    jQuery(this).select();
