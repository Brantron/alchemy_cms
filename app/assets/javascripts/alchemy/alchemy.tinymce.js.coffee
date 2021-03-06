# Alchemy Tinymce wrapper
#
$.extend Alchemy.Tinymce,

  customConfigs: {}

  # Returns default config for a tinymce editor.
  #
  getDefaultConfig: (id) ->
    config = @defaults
    config.language = Alchemy.locale
    config.selector = "#tinymce_#{id}"
    config.init_instance_callback = @initInstanceCallback
    return config

  # Returns configuration for given custom tinymce editor selector.
  #
  # It uses the +.getDefaultConfig+ and merges the custom parts.
  #
  getConfig: (id, selector) ->
    editor_config = @customConfigs[selector]
    if editor_config
      $.extend({}, @getDefaultConfig(id), editor_config)
    else
      @getDefaultConfig(id)

  # Initializes all TinyMCE editors with given ids
  #
  # @param ids [Array]
  #   - Editor ids that should be initialized.
  #
  init: (ids) ->
    for id in ids
      @initEditor(id)

  # Initializes TinyMCE editor with given options
  #
  initWith: (options) ->
    tinymce.init $.extend({}, @defaults, options)
    return

  # Initializes one specific TinyMCE editor
  #
  # @param id [Number]
  #   - Editor id that should be initialized.
  #
  initEditor: (id) ->
    textarea = $("#tinymce_#{id}")
    if textarea.length == 0
      Alchemy.log_error "Could not initialize TinyMCE for textarea#tinymce_#{id}!"
      return
    config = @getConfig(id, textarea[0].classList[1])
    if config
      spinner = Alchemy.Spinner.small()
      textarea.closest('.tinymce_container').prepend spinner.spin().el
      tinymce.init(config)
    else
      Alchemy.debug('No tinymce configuration found for', id)

  # Gets called after an editor instance gets intialized
  #
  initInstanceCallback: (inst) ->
    $this = $("##{inst.id}")
    parent = $this.closest('.element-editor')
    parent.find('.spinner').remove()
    inst.on 'dirty', (e) ->
      Alchemy.setElementDirty(parent)

  # Removes the TinyMCE editor from given dom ids.
  #
  remove: (ids) ->
    for id in ids
      editor = tinymce.get("tinymce_#{id}")
      if editor
        editor.remove()

  # Remove all tinymce instances for given selector
  removeFrom: (selector) ->
    $(selector).each ->
      elem = tinymce.get(this.id)
      elem.remove() if elem
      return
    return
