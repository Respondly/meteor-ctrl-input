###
A rounded checkbox (like iOS / Google Material).

Events:
  - changed

###
Ctrl.define
  'c-checkbox':
    ready: ->
      el = @find()

      # Provide a way for the value to be reset to [undefined]
      # NB: This is used by the data-binder.
      @ctrl.isChecked.delete = =>
          @__internal__.supressBinder = true
          @api.isChecked(null)
          @__internal__.supressBinder = false

      # Sync: CSS classes.
      @autorun =>
          # Setup initial conditions.
          isChecked = @api.isChecked()
          isEnabled = @api.isEnabled()
          hasLeftLabel = not Util.isBlank(@helpers.labelLeft())
          hasRightLabel = not Util.isBlank(@helpers.labelRight())
          hasLabel = hasLeftLabel or hasRightLabel

          # Update CSS classes.
          el.toggleClass 'c-indeterminate', (isChecked is null)
          el.toggleClass 'c-checked', (isChecked is true or isChecked is null)
          el.toggleClass 'c-not-checked', (isChecked is false)
          el.toggleClass 'c-enabled', isEnabled
          el.toggleClass 'c-disabled', not isEnabled
          el.toggleClass 'c-straddle', @api.straddle()
          el.toggleClass 'c-has-label', hasLabel
          el.toggleClass 'c-has-left-label', hasLeftLabel
          el.toggleClass 'c-has-right-label', hasRightLabel
          el.toggleClass 'c-has-message', not Util.isBlank(@helpers.message())

          # Size.
          supportedSizes = [22, 34]
          size = @api.size()
          unless (supportedSizes.any (item) -> item is size)
            throw new Error("Size '#{ size }' not supported. Use one of: #{ supportedSizes }")

          for item in supportedSizes
            el.removeClass "c-size-#{ item }"
            if item is size
              el.addClass "c-size-#{ item }"

      # Finish up.
      isCreated = true
      Util.delay => el.addClass('c-animated')


    destroyed: ->
      @__internal__.binder?.dispose()


    api:
      isEnabled:    (value) -> @prop 'enabled', value, default:true
      isClickable:  (value) -> @prop 'isClickable', value, default:true
      size:         (value) -> @prop 'size', value, default:22

      label:        (value) -> @prop 'label', value, default:null
      onLabel:      (value) -> @prop 'onLabel', value, default:null
      offLabel:     (value) -> @prop 'offLabel', value, default:null
      straddle:     (value) -> @prop 'straddle', value, default:false

      message:      (value) -> @prop 'message', value, default:null
      onMessage:    (value) -> @prop 'onMessage', value, default:null
      offMessage:   (value) -> @prop 'offMessage', value, default:null


      ###
      Gets or sets whether the checkbox is checked.
      @param value: (optional) Boolean value.  Pass nothing to read.
      @param options:
                - silent:     (optional) Flag indicating if the [changed] event should fire (default:true).
                - wasClicked: (optional) Flag indicating if the change originated from a click event.
      ###
      isChecked: (value, options = {}) ->
        result = @prop 'isChecked', value, default:true
        if value isnt undefined
          if options.silent isnt true and (@_lastIsChecked isnt value)
            args =
              isChecked: value
              wasClicked: options.wasClicked ? false
            @trigger('changed', args)
            unless @__internal__.supressBinder
              @__internal__.binder?.onCtrlChanged(value)

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


      ###
      See [Ctrls.DataBinder].
      ###
      bind: (propertyName, modelFactory) ->
        @__internal__.binder?.dispose()
        @__internal__.binder = new Ctrls.DataBinder(@ctrl, 'isChecked', propertyName, modelFactory)


    helpers:
      cssClass: -> @defaultValue('cssClass')

      showLeftLabel: -> @api.straddle() and @api.offLabel()?

      labelLeft: -> @api.offLabel()

      labelRight: ->
        label    = @api.label()
        onLabel  = @api.onLabel()
        offLabel = @api.offLabel()

        if @api.straddle()
          if onLabel then onLabel else label
        else
          switch @api.isChecked()
            when true
              if onLabel then onLabel else label
            when false
              if offLabel then offLabel else label

            when null then label

      message: ->
        message    = @api.message()
        onMessage  = @api.onMessage()
        offMessage = @api.offMessage()

        switch @api.isChecked()
          when true  then onMessage ? message
          when false then offMessage ? message
          when null then message



    events:
      'mousedown': (e) ->
        if @api.isClickable()
          if e.button is 0 and e.target.nodeName isnt 'A'
            @api.click()

      'keydown': (e) ->
        @api.click() if e.which is Const.KEYS.SPACE

