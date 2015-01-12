jQuery ->
  jQuery('.file-list .file').hide()

  jQuery(document).delegate '.ops .op:not(.back)', 'click', ->
    $el = jQuery('.file-list .file:not(:visible)').first()

    $el
      .show(400)
      .addClass 'loading'

    setTimeout =>
      $el.removeClass 'loading'
    , 2000


  jQuery(document).delegate '.file-list .file .op.close', 'click', ->
    jQuery(this).closest('.file').hide(400)

  jQuery(document).delegate '.url', 'click', ->
    jQuery(this).select()