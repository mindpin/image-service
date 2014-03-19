jQuery ->
  $add_options    = jQuery(".add-option")
  $active_options = jQuery(".active-option")

  $add_options.find("button").on "click", ->
    $parent = jQuery(this).parent()
    name    = $parent.data("option")

    value = $parent.find("input").map ->
      ~~jQuery(this).val()

    value = if 1 == value.length
      value[0]
    else
      [value[0], value[1]]

    data = {option: {}}
    data.option[name] = value

    deferred = jQuery.ajax
      type: "PUT"
      url:  "/settings"
      data: data

    deferred.done (res)=>
      jQuery(".active-options").html(res)
      $parent.find("input").val("")
      jQuery(this).attr("disabled", true)

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

    data = {option: {}}
    data.option[name] = $parent.data("value")

    deferred = jQuery.ajax
      type: "DELETE"
      url:  "/settings"
      data: data

    deferred.done (res)=>
      $parent.remove()
