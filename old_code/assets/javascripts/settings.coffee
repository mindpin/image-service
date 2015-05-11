jQuery ->
  $add_options    = jQuery(".add-option")
  $active_options = jQuery(".active-option")

  $add_options.find("button").on "click", ->
    $parent = jQuery(this).parent()
    name    = $parent.data("option")
    add_setting_url = $parent.data("add-setting-url")

    value = jQuery.makeArray($parent.find("input")).map (e)->
      ~~jQuery(e).val()

    console.log value

    data = {option: {}}
    data.option[name] = value

    deferred = jQuery.ajax
      type: "POST"
      url:  add_setting_url
      data: data

    deferred.done (res)=>
      jQuery(".active-options").html(res)
      $parent.find("input").val("")
      jQuery(this).attr("disabled", true)
      jQuery(this).fadeOut()

  $add_options.find("input").on "change", ->
    $parent = jQuery(this).parent()
    $button = jQuery(this).next("button")

    $invalid_input = $parent.find("input").filter ->
      ~~jQuery(this).val() <= 0

    if $invalid_input.length > 0
      $parent.data("invalid", true)
    else
      $parent.data("invalid", false)

    if !$parent.data("invalid")
      $button.attr("disabled", false)
      $button.fadeIn()
    else
      $button.attr("disabled", true)
      $button.fadeOut()

  jQuery(document).on "click", ".active-options button", ->
    $parent = jQuery(this).parent()
    name    = $parent.data("option")
    delete_setting_url = $parent.data("delete-setting-url")

    data = {option: {}}
    data.option[name] = $parent.data("value")

    deferred = jQuery.ajax
      type: "DELETE"
      url:  delete_setting_url
      data: data

    deferred.done (res)=>
      $parent.remove()
