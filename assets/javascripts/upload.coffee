jQuery ->
  $image_upload = jQuery(".image-upload")
  $fileinput = jQuery(".upload input[type=file]")
  $uploading_list = jQuery(".uploading-list")
  $uploading_template = $uploading_list.find(".uploading.template")

  class FileUploader
    constructor: (@file)->
      @data = new FormData
      @data.append "file", @file, @file.name

    before: (fn)->
      @before = fn

    request: (url)->
      @before()
      jQuery.ajax
        type : "POST"
        contentType : false
        processData : false
        url         : url
        data        : @data

  upload = (file, name)->
    file.name = name if name
    uploader = new FileUploader(file)

    uploader.before ->
      $image_upload.addClass("moveup")
      $uploading = $uploading_template.clone()

      file.elm = $uploading

      $uploading.find(".filename").text(file.name)
      $uploading_list.fadeIn()
      $uploading_list.append($uploading)
      $uploading.fadeIn()

    deferred = uploader.request("/images")

    deferred.done (res)->
      file.elm.find("i").fadeOut()
      file.elm.find("a").attr("href", "/images/#{res.filename.split('.')[0]}").fadeIn()
    
  jQuery(".select-file").on "click", ->
    $fileinput.trigger("click")

  jQuery(document).on "dragover", (event)->
    event.stopPropagation()
    event.preventDefault()

  jQuery(document).on "dragenter", (event)->
    event.stopPropagation()
    event.preventDefault()

  jQuery(document).on "drop", (event)->
    event.stopPropagation()
    event.preventDefault()

    files = event.originalEvent.dataTransfer.files

    for file in files
      upload(file)

  jQuery(".upload input[type=file]").on "change", ->
    files = $fileinput[0].files
    for file in files
      upload(file)

  jQuery(document).on "paste", (event)->
    items = (event.clipboardData || event.originalEvent.clipboardData).items

    for i in items
      if i.type.match(/^image\/\w+$/) 
        file = i.getAsFile()
        upload(file, "image#{(new Date).valueOf()}.png") if file
