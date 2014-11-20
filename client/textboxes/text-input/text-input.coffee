###
An <INPUT> textbox.

Events:
  - changed
  - keydown
  - keyup

  - focus
  - blur

  - enter (key press)
  - key:enter:  The enter key was pressed.
  - key:esc:    The escape key was pressed.

###
Ctrl.define
  'c-text-input':
    init: ->
      @data ?= {}
      @options ?= {}


    ready: ->
      # Setup initial conditions.
      @api.text(Util.asValue(@data.text))
      editableCtrl = @editableCtrl = @findChild('c-content-editable')

      # Bubble events.
      editableCtrl.on 'focus', (j,e) => @trigger 'focus', e
      editableCtrl.on 'blur', (j,e) =>
          @trigger 'blur', e
          @helpers.updateHoverEdit()

      editableCtrl.on 'keydown',   (j,e) => @trigger 'keydown', e
      editableCtrl.on 'keyup',     (j,e) => @trigger 'keyup', e
      editableCtrl.on 'key:esc',   (j,e) => @trigger 'key:esc', e
      editableCtrl.on 'key:enter', (j,e) =>
          @trigger 'enter', e
          @trigger 'key:enter', e


      # Provide a way for the text to be reset to [undefined]
      # NB: This is used by the data-binder.
      supressBinder = false
      @ctrl.text.delete = =>
          supressBinder = true
          @api.clear()
          supressBinder = false


      # Wire up events.
      editableCtrl.on 'changed', (j, e) =>
          @trigger('changed', e)
          @helpers.updateHoverEdit()
          @helpers.updateInputText()
          if not supressBinder
            @__internal__.binder?.onCtrlChanged(e.text)

      # Sync: Update input when related state changes.
      @autorun =>
          isEnabled = @api.isEnabled()
          canEdit   = @api.canEdit()
          multiLine = @api.multiLine()

          Deps.nonreactive =>
            editableCtrl.isEnabled(isEnabled)
            editableCtrl.canEdit(canEdit)

            Deps.afterFlush =>
              @helpers.updateInputText()
              @helpers.updateCss()

      # Sync: Update [can-edit] when the [hover-edit] value changes.
      @autorun =>
          hoverEdit = @api.hoverEdit()
          @api.canEdit(false) if hoverEdit is true

      # Sync: Sundry textbox values.
      @autorun =>
          editableCtrl.placeholder(@api.placeholder())
          editableCtrl.maxLength(@api.maxLength())
          editableCtrl.multiLine(@api.multiLine())
          editableCtrl.selectOnFocus(@api.selectOnFocus())

      # Sync: Update visual state.
      @autorun =>
          @api.error()
          @helpers.updateCss()

      # Sync: Spinner.
      @autorun => @editableCtrl.isSpinning(@api.isSpinning())


      # Force the label width after a delay if it's not visible at time of creation.
      if @api.labelAutoWidth() is true
        el = @find('> label')
        if not el.is(':visible')
          Util.delay => @helpers.updateLabelPosition()

      # Finish up.
      @helpers.updateHoverEdit()


    destroyed: ->
      @__internal__.binder?.dispose()


    api:
      label:          (value) -> @prop 'label',       value
      required:       (value) -> @prop 'required',    value, default:false

      placeholder:    (value) -> @prop 'placeholder', value,
      maxLength:      (value) -> @prop 'maxLength',   value, default: 500
      canEdit:        (value) -> @prop 'canEdit',     value, default: true
      isEnabled:      (value) -> @prop 'enabled',     value, default: true
      multiLine:      (value) -> @prop 'multiLine',   value, default: false
      prefix:         (value) -> @prop 'prefix',      value

      focus: -> @editableCtrl?.focus()
      hasFocus: -> @editableCtrl?.hasFocus() ? false
      caretToEnd: -> @editableCtrl?.caretToEnd()

      isEmpty:  -> Util.isBlank(@api.text())
      hasValue: -> not @api.isEmpty()

      hoverEdit:      (value) -> @prop 'hoverEdit',      value, default: false
      isValid:        (value) -> @prop 'isValid',        value, default:null
      isSpinning:     (value) -> @prop 'isSpinning',     value, default: false
      isSearch:       (value) -> @prop 'isSearch',       value, default: false
      message:        (value) -> @prop 'message',        value, default: ''
      error:          (value) -> @prop 'error',          value, default: ''
      labelAutoWidth: (value) -> @prop 'labelAutoWidth', value, default: false
      labelPosition:  (value) -> @prop 'labelPosition',  value, default: 'left' # Values: left | top
      selectOnFocus:  (value) -> @prop 'selectOnFocus',  value, default: true

      hasLabel: -> @api.label()?
      hasMessage: -> not Util.isBlank(@api.message())
      hasError: ->
        error = @api.error()
        return not error.isBlank() if Object.isString(error)
        return error if Object.isBoolean(error)
        false

      clear: -> Deps.nonreactive => @api.text('')
      empty: -> @api.clear()


      ###
      Sets up a Model data-binding for the textbox.
      See [Ctrls.DataBinder].
      ###
      bind: (propertyName, modelFactory) ->
        @__internal__.binder?.dispose()
        @__internal__.binder = new Ctrls.DataBinder(@ctrl, 'text', propertyName, modelFactory)



      ###
      Gets or sets the current text value.
      ###
      text: (value) -> @editableCtrl?.text(value)


      ###
      Forces an update to the current visual state of the control.
      ###
      updateState: ->
        @api.text(@api.text())
        @helpers.updateCss()


    helpers:
      label: ->
        label = @api.label() ? ''
        label = 'Untitled' if label.isBlank()
        label
      hasLabel: -> @api.hasLabel()

      required:        -> @api.required() and @api.isEmpty()
      showInput:       -> @api.canEdit() and @api.isEnabled()
      showErrorIcon:   -> @api.hasError() and not @api.isSpinning()
      showTickIcon:    -> @api.isValid() is true and not @api.hasError() and not @api.isSpinning()

      message: ->
        error   = @api.error()
        message = @api.message()
        return error   if not Util.isBlank(error) and Object.isString(error)
        return message if not Util.isBlank(message)


      inputCtrl: ->
        Deps.nonreactive =>
          options =
            placeholder:  @api.placeholder()
            maxLength:    @api.maxLength()
            multiLine:    @api.multiLine()
            text:         @api.text()
            canEdit:      @api.canEdit()
            isPlainText:  true



      hasPrefix: -> @api.prefix()?
      prefixHtml: ->
        # NB: [true] may be specified, which causes the prefix box to show
        #     so an icon can be placed on it within CSS.
        prefix = @api.prefix()
        prefix = '' unless Object.isString(prefix)
        prefix


      updateHoverEdit: ->
        return unless @api.hoverEdit() is true
        canEdit = false
        canEdit = true if @hasFocus()
        canEdit = true if @isOver
        canEdit = true if @api.isEmpty()
        @api.canEdit(canEdit) unless @api.canEdit() is canEdit


      updateInputText: ->
        if ctrl = @editableCtrl
          if el = @find()
            # Sync the height of the textbox.
            if @api.multiLine() or @api.labelPosition() is 'top'
              Deps.afterFlush => @helpers.updateHeight()
            else
              @find().css 'min-height', ''



      updateHeight: ->
        height = @find('.c-input').outerHeight()
        if @api.labelPosition() is 'top'
          height += @find('label').outerHeight() + 6
        @find().css 'min-height', "#{ height }px"


      updateLabelPosition: ->
        # Adjust the left-hand side of the INPUT to with width of the label.
        elInput = @find('.c-input')
        if @api.hasLabel() and @api.labelPosition() is 'left'
          if @api.labelAutoWidth() is true
            elInput.css 'left', (@find('> label').outerWidth() + 10) + 'px'
          else
            elInput.css 'left', ''
        else
          elInput.css 'left', '0px'


      updateMessagePosition: ->
        # Place the message flush with the left edge of the INPUT.
        hasStringError  = @api.hasError() and Object.isString(@api.error())
        if elInput = @find('div.c-input')
          elMessage = @find('.c-message')
          elMessage.css 'margin-left', elInput.css('left')
          elMessage.toggle(@helpers.message()?)
          elMessage.toggleClass('c-error', hasStringError)


      updateCss: ->
        isEmpty         = @api.isEmpty()
        isEnabled       = @api.isEnabled()
        multiLine       = @api.multiLine()
        canEdit         = @api.canEdit()
        labelPosition   = @api.labelPosition()
        hasStringError  = @api.hasError() and Object.isString(@api.error())

        if el = @find()
          el.toggleClass 'has-text', not isEmpty
          el.toggleClass 'is-empty', isEmpty
          el.toggleClass 'is-enabled', isEnabled
          el.toggleClass 'disabled', not isEnabled
          el.toggleClass 'is-valid', @api.isValid() is true
          el.toggleClass 'is-spinning', @api.isSpinning() is true
          el.toggleClass 'is-required', @api.required() is true
          el.toggleClass 'is-search', @api.isSearch() is true
          el.toggleClass 'has-error', @api.hasError()
          el.toggleClass 'has-message', @api.hasMessage() and not hasStringError
          el.toggleClass 'has-label', @api.hasLabel()
          el.toggleClass 'can-edit', canEdit
          el.toggleClass 'cannot-edit', not canEdit
          el.toggleClass 'multi-line', multiLine
          el.toggleClass 'single-line', not multiLine
          el.toggleClass 'has-prefix', @api.prefix()?
          el.toggleClass 'label-left', labelPosition is 'left'
          el.toggleClass 'label-top', labelPosition is 'top'

          if cssClass = @defaultValue('cssClass')
            el.addClass(cssClass)

          # Finish up.
          @helpers.updateLabelPosition()
          @helpers.updateMessagePosition()
          @helpers.updateHeight()


      events:
        'mouseenter .c-input': ->
          @isOver = true
          @helpers.updateHoverEdit()

        'mouseleave .c-input': ->
          @isOver = false
          @helpers.updateHoverEdit()



