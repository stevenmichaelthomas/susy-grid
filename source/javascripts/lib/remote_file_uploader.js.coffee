#-----------------------------------------------------------------------------
# Remote File Uploader
#-----------------------------------------------------------------------------

class @RemoteFileUploader

  #-----------------------------------------------------------------------------
  # Class Constants
  #-----------------------------------------------------------------------------

  @UPLOAD_ENDPOINT = null
  @UPLOAD_PARAMS   = null

  do =>
    $.getJSON 'http://metalab-website-service.herokuapp.com/signed_url', (data) =>
      @UPLOAD_ENDPOINT = data.url
      @UPLOAD_PARAMS   = data.multipart_params


  #-----------------------------------------------------------------------------
  # Constructor
  #-----------------------------------------------------------------------------

  constructor: (@el) ->
    @files = []
    return false unless (window.File && window.FileReader && window.FileList && window.Blob)

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  render: ->
    return if @isRendered

    # View
    @drop   = document.createElement('div')
    @label  = document.createElement('label')
    @output = document.createElement('output')
    @list   = document.createElement('ul')

    @el.className += ' remote-file-uploader'

    @drop.className   = 'remote-file-uploader-dropzone'
    @label.className  = 'remote-file-uploader-dropzone-label'
    @output.className = 'remote-file-uploader-output'
    @list.className   = 'remote-file-uploader-output-list'

    @label.innerHTML = 'Drag &amp; drop files here to upload'

    @output.appendChild(@list)

    @drop.appendChild(@output)

    @el.appendChild(@label)
    @el.appendChild(@drop)

    # Events
    @drop.addEventListener('drop',     @onDrop,    false)
    @drop.addEventListener('drag',     @onDrag,    false)
    @drop.addEventListener('dragover', @onDrag,    false)
    @drop.addEventListener('dragend',  @onDragEnd, false)

    @list.addEventListener('click', @onClick, false)

    # Done
    @isRendered = true
    return this

  upload: (files...) ->
    for file in files
      do (file) =>
        size  = file.size
        e     = Math.floor(Math.log(size) / Math.log(1000))
        size  = (size / Math.pow(1000, e)).toFixed(0)
        units = "b Kb Mb Gb Tb Pb".split(" ")[e]

        li       = document.createElement('li')
        progress = document.createElement('progress')

        li.className = 'remote-file-uploader-output-list-item'
        li.innerHTML = """
          <span class="name">#{file.name.replace(/[<>]/g, '')}</span>
          <span class="type">#{file.type or 'n/a'}</span>
          <span class="size">#{size}</span><span class='units'>#{units}</span>
        """

        progress.min       = 0
        progress.max       = 100
        progress.value     = 0
        progress.innerText = '0% complete'

        li.appendChild(progress)
        @list.appendChild(li)

        upload =
          listItem: li
          progress: progress

        # XXX Retry?
        if @constructor.UPLOAD_ENDPOINT isnt null and @constructor.UPLOAD_PARAMS isnt null
          @_send(file, upload)

  _send: (data, upload) ->
    formData = new FormData
    formData.append(key, value) for key, value of @constructor.UPLOAD_PARAMS
    formData.append('file', data, data.name)

    xhr = new XMLHttpRequest()
    xhr.open('POST', @constructor.UPLOAD_ENDPOINT, true)

    xhr.onload = (event) =>
      upload.listItem.classList.remove('uploading')

      if xhr.status is 201
        remove           = document.createElement('a')
        remove.href      = '#'
        remove.className = 'remove'
        remove.innerText = 'Remove'

        input       = document.createElement('input')
        input.type  = 'hidden'
        input.name  = 'file[]'
        input.value = event.target.responseXML.querySelector('Key').textContent

        upload.listItem.appendChild(remove)
        upload.listItem.appendChild(input)
        upload.listItem.classList.add('uploaded')
      else
        xhr.onerror.call(this, event)

      return

    xhr.onerror = (event) ->
      upload.listItem.classList.remove('uploading')
      upload.listItem.classList.add('failed')

      return

    xhr.upload.onprogress = (event) ->
      if event.lengthComputable
        upload.progress.value = (event.loaded / event.total) * 100
        upload.progress.textContent = "#{upload.progress.value}%"

      return

    upload.listItem.classList.add('uploading')
    xhr.send(formData)


  #-----------------------------------------------------------------------------
  # Event Listeners
  #-----------------------------------------------------------------------------

  onDrag: (event) =>
    event.stopPropagation()
    event.preventDefault()
    event.dataTransfer.dropEffect = 'copy'
    @drop.classList.add('drag-enter')

  onDragEnd: (event) =>
    @drop.classList.remove('drag-enter')

  onDrop: (event) =>
    event.stopPropagation()
    event.preventDefault()
    @drop.classList.remove('drag-enter')
    @upload(event.dataTransfer.files...)

  onClick: (event) =>
    if event.target.classList.contains('remove')
      event.preventDefault()
      event.stopPropagation()
      event.target.parentNode.parentNode.removeChild(event.target.parentNode)
