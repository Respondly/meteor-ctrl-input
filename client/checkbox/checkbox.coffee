###
A simple checkbox.

Events:
  - changed

###
Ctrl.define
  'c-checkbox':
    init: ->
      @helpers.triggerChanged = @helpers.triggerChanged.debounce()


    ready: ->
      @autorun => @api.updateState()

      onCreated = =>
          @api.updateState()
          @data?._onCreated?(@ctrl)

      setLoaded = => @find().addClass 'is-loaded'

      # Keep the API in sync with the UI control.
      @autorun =>
        isChecked = @children.chkMain.isChecked()
        Deps.nonreactive => @api.isChecked(isChecked)

      renderChild = (def) =>
          def.ctrl = @appendCtrl('c-checkbox', '> .c-children > .c-inner', data:def)

          onChildChanged = (e) =>
              e.parent = @ctrl
              e.isChild = true
              e.def = def
              @api.updateState()
              @helpers.updateIsIndeterminate()
              def.onChanged?(e)
              @helpers.triggerChanged()
          onChildChanged = onChildChanged.debounce()

          # Wire up events.
          def.ctrl.on 'changed', (j, e) =>
            if e.ctrl is def.ctrl
              onChildChanged(e) # Child control changed.
            else
              @helpers.triggerChanged() # Bubble deeper descendent's changed event..



      # SYNC: Child checkboxes within DOM.
      @autorun =>
        defs = @api.children()
        if defs = @api.children()
          # Wait for the container element to be drawn.
          Deps.afterFlush =>
            renderChild(def) for key, def of defs

          # Update state.
          Deps.afterFlush => @helpers.updateIsIndeterminate()



      # Default load the children if there are any.
      if childDefs = @defaultValue('children')

        # Load the child checkboxes.
        @api.children childDefs, callback: =>
          Deps.afterFlush =>
            # Update the is-open state.
            if @api.isChild()
              # CHILD checkbox.
              @api.isOpen(true) # Child checkboxes are always open.
              onCreated()

            else
              # ROOT checkbox.

              # If this is the root checkbox, check if an explicit "isChecked" value was
              # specified, and if so update it (overriding all child values).
              defaultIsChecked = @defaultValue('isChecked')
              if defaultIsChecked isnt undefined
                @api.isChecked(defaultIsChecked)

              # Open the root checkbox if explicitly declared.
              defaultIsOpen = @defaultValue('isOpen', false)
              if defaultIsOpen is true
                @api.isOpen(true)

              # Open the root checkbox if in an indeterminate state.
              @helpers.updateIsIndeterminate()
              if not @api.isOpen() and @api.isChecked() is null and @api.openWhenIndeterminate()
                @api.isOpen(true)

              # Finish up.
              Util.delay =>
                # NB: The transition animation is set after initial load so that
                #     the control does not animate while being rendered for the first time.
                onCreated()
                setLoaded()

      else
        # No child checkboxes.
        onCreated()
        setLoaded()



    api:
      label: (value) -> @prop 'label', value
      message: (value) -> @prop 'message', value, default:null
      isEnabled: (value) -> @prop 'enabled', value, default:true
      openWhenIndeterminate: (value) -> @prop 'open-indeterminate', value, default:true

      toggle: -> @api.isChecked( not @api.isChecked() )

      ###
      Gets or sets whether the checkbox is currently checked.
      @param value: Boolean.
      @param options:
                - silent: Flag indicating whether the 'changed' event should be supressed. Default:false
      ###
      isChecked: (value, options = {}) ->
        prop = (value) => @prop 'isChecked', value, default:false

        if value isnt undefined
          # WRITE.
          originalValue = Deps.nonreactive -> prop()
          if value isnt null
            if defs = @api.children()
              for key, def of defs
                def.ctrl?.isChecked(value, silent:true)

          # Alert listeners (unless supressed).
          unless options.silent is true
            fireEvent = true if value isnt originalValue

        # Finish up.
        result = prop(value)
        @helpers.triggerChanged() if fireEvent
        result



      ###
      Gets or sets the [isChecked] state, and the state of the children, as an object.
      @returns value: Specified when writing
                        {
                          isChecked:Boolean
                          children:
                            <key>: <value>
                        }
      @param options:
                - silent: Flag indicating whether the 'changed' event should be supressed. Default:false
      ###
      value: (value, options = {}) ->
        # WRITE.
        if value isnt undefined
          if value is null or Object.isBoolean(value)
            # Simple value was passed, pass off to the is-checked method.
            @api.isChecked(value, options)

          if Util.isObject(value)
            childDefs = @api.children()

            # Update "isChecked" state.
            isChecked = value.isChecked
            if isChecked isnt undefined
              @api.isChecked(isChecked, options) if @api.isChecked() isnt isChecked

            # Write child values.
            #   Updates occur "top-to-bottom" allowing a top level value to be set (true/false)
            #   and then lower level values to override that, turning on say one or two child options.
            #   This type of overriding order is the equivalent of styles (inline styles overriding the style-sheet).
            for key, item of value
              if key isnt 'isChecked'
                # Process child hierarchy before updating the 'isChecked' value on this checkbox.
                def = childDefs[key]
                def.ctrl?.value(item, options) # <== RECURSION.


        # READ.
        result = { isChecked:@api.isChecked() }
        if childDefs = @api.children()
          for key, def of childDefs
            unless key is 'isChecked' # Edge-case, don't overwrite a checkbox with the ID of 'isChecked'.  Stupid if anyone uses this as an ID!
              result[key] = def.ctrl?.value()

        # Finish up.
        result


      updateState: ->
        # Setup initial conditions.
        isEnabled = @helpers.isEnabled()
        isChecked = @api.isChecked()
        isChild   = @api.isChild()
        message   = @api.message()

        # Inherit parent checkbox values (if this is a sub-checkbox).
        if isChild
          isEnabled = false unless @parent.api.isEnabled()

        # CSS classes.
        if el = @find()
          el.toggleClass 'is-child', isChild

        # Checked state.
        if chk = @children.chkMain
          chk.isChecked(isChecked)
          chk.isEnabled(isEnabled)
          chk.message(message)

        # Open state (when child defs).
        if childDefs = @api.children()
          isOpen = @api.isOpen()
          @children.twisty?.isOpen(isOpen)

          el = @find('> .c-children')
          Deps.afterFlush =>
            height = if isOpen then el.find('> .c-inner').outerHeight() else 0
            el.css 'height', height + 'px'


      ###
      Gets or sets an object containing the definition of child-options for the checkbox.
      @param value:
                <item-id>:  (values can be functions or simple values).
                  - label
                  - message
                  - isEnabled
                  - isChecked
      @param options:
              - callback: When writing invoked when all children are loaded
      ###
      children: (value, options = {}) ->
        prop = (v) => @prop('child-defs', v)

        if value isnt undefined

          # Dispose of existing values.
          if existing = prop()
            for key, def of existing
              def.ctrl?.dispose()

          # WRITE - process value.
          if value is null
            @api.isChecked(false) if @api.isChecked() is null
          else
            count = 0
            for key, item of value
              count += 1
              do (key, item) =>
                item.id ?= key # Ensure each item has an id.
                item.isChecked = false if item.isChecked is undefined
                item._onCreated = =>
                        count -= 1
                        delete item._onCreated
                        options.callback?() if count is 0

            Util.delay => @api.updateState()


        result = prop(value)
        result

      ###
      Gets or sets whether the children options are showing (the twisty is open).
      Only relevant when [children] is set.
      ###
      isOpen: (value) -> @prop 'open', value, default:false

      ###
      Determines whether the checkbox sports child options.
      ###
      hasChildren: -> @api.children()?

      ###
      Gets whether this checkbox is a child of another checkbox.
      ###
      isChild: -> @parent?.type is @type

      ###
      Gets whether this is the root checkbox (is not a child of another checkbox).
      ###
      isRoot: -> not @api.isChild()


      ###
      Walks up the hierarchy of checkboxes.
      @param func(bool): The function to invoke.
                         Return False to stop walking.
      ###
      walk: (func) ->
        walk = (checkboxCtrl) ->
          if checkboxCtrl
            result = func(checkboxCtrl)
            if result isnt false # Stop.
              if checkboxCtrl.isChild()
                walk(checkboxCtrl.parent) # <== RECURSION.
        walk(@ctrl)



    helpers:
      cssClass: ->
        css = @defaultValue('cssClass', '')
        css += ' c-root' if @api.isRoot()
        css


      label: ->
        label = @api.label()
        label = 'Untitled' if Object.isString(label) and label.isBlank()
        label = '' if label is null
        label

      showRequired: ->
        if @defaultValue('required') is true
          not @api.isChecked()


      triggerChanged: ->
        args =
          isChecked: @api.isChecked()
          value: @api.value()
          ctrl: @ctrl
        @trigger 'changed', args


      isEnabled: ->
        # Calculate the enabled state, accounting for any parents
        # that may be disabled.
        result = true
        @api.walk (checkboxCtrl) ->
          unless checkboxCtrl.isEnabled()
            result = false
            false # Stop walking.
        result

        # Finish up.
        Deps.afterFlush => @helpers.updateIsIndeterminate()
        result



      calculateIsChecked: (childDefs) ->
        if defs = childDefs

          allChildrenChecked = true
          noChildrenChecked = true

          # Determine whether there is an all-or-nothing set of selections.
          for key, def of defs
            isChecked = if def.ctrl
                          def.ctrl.isChecked()
                        else
                          Util.asValue(def.isChecked)

            allChildrenChecked = false if isChecked is false or isChecked is null
            noChildrenChecked  = false if isChecked or isChecked is null

          # Update the is-checked value.
          value = true if allChildrenChecked
          value = false if noChildrenChecked
          value = null if (allChildrenChecked is false and noChildrenChecked is false)
          value


      updateIsIndeterminate: ->
        isChecked = @helpers.calculateIsChecked(@api.children())
        @api.isChecked(isChecked) if @api.isChecked() isnt isChecked





    events:
      'click .c-twisty': (e) -> @api.isOpen(not @api.isOpen())

      'change input[type="checkbox"]': (e) ->
        # Update the [isChecked] state.
        @api.isChecked(e.target.checked)


