jQuery ->
  $fileinput = jQuery(".upload input[type=file]")

  jQuery(".select-file").on "click", ->
    $fileinput.trigger("click")

  jQuery(".upload input[type=file]").on "change", ->
    filename = $fileinput[0].files[0].name
    jQuery(".upload button").fadeIn()
    jQuery(".select-file .txt").text("已选择: #{filename}")
