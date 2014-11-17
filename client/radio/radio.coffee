###
A rounded radio-button.

Events:
  - changed

###
Ctrl.define
  'c-radio':
    init: ->
      @autorun =>
          # Size.
          supportedSizes = [22, 34]
          size = @api.size()
          unless (supportedSizes.any (item) -> item is size)
            throw new Error("Size '#{ size }' not supported. Use one of: #{ supportedSizes }")

    ready: ->


    api:
      isEnabled:    (value) -> @prop 'isEnabled', value, default:true
      size:         (value) -> @prop 'size', value, default:@defaultValue('size', 22)
      isClickable:  (value) -> @prop 'isClickable', value, default:@defaultValue('isClickable', true)

      ###
      Gets or sets whether the checkbox is checked.
      @param value: (optional) Boolean value.  Pass nothing to read.
      @param options:
                - silent:     (optional) Flag indicating if the [changed] event should fire (default:true).
                - wasClicked: (optional) Flag indicating if the change originated from a click event.
      ###
      isChecked: (value, options = {}) ->
        result = @prop 'isChecked', value, default:false
        if value isnt undefined
          if options.silent isnt true and (@_lastIsChecked isnt value)
            args =
              isChecked: value
              wasClicked: options.wasClicked ? false
            @trigger('changed', args)
          @_lastIsChecked = value
        result


      ###
      Toggles the is-checked state of the button.
      @param toggle: (optional) The is-checked state.
      @param options:
                - silent:     (optional) Flag indicating if the [changed] event should fire (default:true).
                - wasClicked: (optional) Flag indicating if the change originated from a click event.
      ###
      toggle: (toggle, options = {}) ->
        if Util.isObject(toggle)
          options = toggle
          toggle = undefined
        toggle = not @api.isChecked() if toggle is undefined
        @api.isChecked(toggle, options)


      ###
      The result of a click event.
      ###
      click: ->
        if @api.isEnabled()
          @api.toggle(wasClicked:true)
          @ctrl.focus()


    helpers:
      cssClass: ->
        isChecked = @api.isChecked()
        isEnabled = @api.isEnabled()
        css = ''
        css += ' c-checked' if isChecked
        css += ' c-not-checked' if isChecked is false
        css += ' c-enabled' if isEnabled
        css += ' c-disabled' if not isEnabled

        css

    events:
      'mousedown': (e) ->
        if @api.isClickable()
          @api.click() if e.button is 0

      'keydown': (e) ->
        @api.click() if e.which is Const.KEYS.SPACE

