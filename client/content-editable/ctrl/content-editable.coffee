###
A simple UI control wrapper around the [ContentEditable] controller.

Events:
  - changed
  - keydown
  - keyup

  - blur
  - focus

  - key:enter:  The enter key was pressed.
  - key:esc:    The escape key was pressed.

###
Ctrl.define
  'c-content-editable':
    init: ->
      @textbox = textbox = new Ctrls.ContentEditable(@id)
      textbox.maxLength(@defaultValue('maxLength', null))
      textbox.canEdit(@defaultValue('canEdit', true))
      @api.selectOnFocus(@defaultValue('selectOnFocus', false))
      @api.multiLine(@defaultValue('multiLine', true))
      @api.isPlainText(@defaultValue('isPlainText', true))


    ready: ->
      elTextbox = @find('> .c-textbox')
      initialHtml = @textbox.session.prop('html') ? ''

      # Set the min-height of the textbox element.
      #   NB: This is to prevent a bug in Firefox which reports
      #       zero height when the textbox is empty.
      elTextbox.html('&nbsp;')
      elTextbox.css 'min-height', elTextbox.outerHeight() + 'px'
      elTextbox.html(initialHtml)

      # Initialize the textbox controller.
      @textbox.init(elTextbox)

      # Setup placeholder styles.
      padding = @find().style().padding()
      @find('.c-placeholder').style().padding(padding)

      # Bubble events.
      bubble = (eventName) => @textbox.on eventName, (j,e) => @trigger(eventName, e)
      bubble('blur')
      bubble('focus')
      bubble('keydown')
      bubble('keyup')
      bubble('changed')
      bubble('key:enter')
      bubble('key:esc')

      # Focus/blur.
      @textbox.on 'focus', (j,e) => @find().addClass 'focused'
      @textbox.on 'blur', (j,e) => @find().removeClass 'focused'
      @textbox.el.on 'paste', (e) => setPlaceholder(false)

      # Keep CSS classes in sync.
      @autorun =>
            canEdit = @api.canEdit()
            isEnabled = @api.isEnabled()

            el = @find()
            toggle = (cssClass, value) -> el.toggleClass(cssClass, value)
            toggle 'c-scrolling', @api.scrolling()
            toggle 'c-spinning', @api.isSpinning()
            toggle 'is-empty', @api.isEmpty()
            toggle 'is-blank', @api.isBlank()
            toggle 'has-content', not @api.isEmpty()

            toggle 'can-edit', canEdit
            toggle 'cannot-edit', not canEdit

            toggle 'is-enabled', isEnabled
            toggle 'disabled', not isEnabled

      # Keep placeholder in sync.
      setPlaceholder = (show) =>
            placeholder = if show then @api.placeholder() else ''
            el = @find('.c-placeholder')
            el.html(placeholder)
            el.toggle(show)

      @autorun => setPlaceholder(@api.isBlank())
      @textbox.on 'keydown', (j, e) =>
            # NOTE: This key-down check allows for pre-emptive removal of the placholder.
            #       on the initial keystroke to avoid typed text sitting over the
            #       placeholder until the key-up event fires.
            setPlaceholder(false) if @api.isBlank() and e.isContentKey() and not e.is.enter

      # Sync: Spinner.
      @autorun =>
          if @api.isSpinning()
            SPINNER_HEIGHT  = 22
            el              = @find()
            padding         = el.style().padding()
            Util.delay =>
              elSpinner = @find('.c-spinner')
              spinnerStyle    = @find('.c-spinner').style()
              height          = el.outerHeight()
              right           = padding.right

              top = if height <= 30
                      (height / 2) - (SPINNER_HEIGHT / 2) # Vertical align.
                    else
                      padding.top

              spinnerStyle.top(top)
              spinnerStyle.right(right)



    destroyed: ->
      @textbox.dispose()
      @_bind?.dispose()


    api:
      ###
      REACTIVE: The placeholder text to display when not the textbox is empty.
      ###
      placeholder: (value) -> @prop 'placeholder', value

      ###
      REACTIVE: Flag indicating whether the textbox scrolls.
      ###
      scrolling: (value) -> @prop 'scrolling', value, default:false


      ###
      REACTIVE: Flag indicating whether the spinner is visible.
      ###
      isSpinning: (value) -> @prop 'spinning', value, default:false


      ###
      Sets up a Model data-binding for the textbox.
      See [TextboxBinder].
      ###
      bind: (propertyName, modelFactory, options = {}) ->
        @_bind?.dispose()
        @_bind = new Ctrls.TextboxBinder(@ctrl, propertyName, modelFactory, options)



      # Wrapped methods --------------------------------------------------

      html: (value) -> @textbox.html(value)
      text: (value) -> @textbox.text(value)
      canEdit: (value) -> @textbox.canEdit(value)
      isEnabled: (value) -> @textbox.isEnabled(value)
      isPlainText: (value) -> @textbox.isPlainText(value)
      updateState: -> @textbox.updateState()
      length: -> @textbox.length()
      isEmpty: -> @textbox.isEmpty()
      isBlank: -> @textbox.isBlank()
      focus: -> @textbox.focus()
      blur: -> @textbox.blur()
      hasFocus: -> @textbox.hasFocus()
      selectAll: -> @textbox.selectAll()
      caretToEnd: -> @textbox.caretToEnd()
      empty: -> @textbox.empty()
      clear: -> @textbox.clear()
      isOverflowing: -> @textbox.isOverflowing()
      scrollHeight: -> @textbox.scrollHeight()
      maxLength: (value) -> @textbox.maxLength(value)

      selectOnFocus: (value) ->
        @textbox.selectOnFocus = value if value isnt undefined
        @textbox.selectOnFocus

      scrollParent: (value) ->
        @textbox.scrollParent = value if value isnt undefined
        @textbox.scrollParent

      multiLine: (value) ->
        @textbox.multiLine = value if value isnt undefined
        @textbox.multiLine

      onKeydown: (func) -> @textbox.onKeydown(func)
      onKeyup:   (func) -> @textbox.onKeyup(func)
      onBlur:    (func) -> @textbox.onBlur(func)
      onFocus:   (func) -> @textbox.onFocus(func)


    helpers:
      cssClass: -> @defaultValue('cssClass')
      isSpinning: -> @api.isSpinning()

    events:
      'click': -> @api.focus()





