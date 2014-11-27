###
A set of radio buttons.

Events:
  - changed

###
Ctrl.define
  'c-radios':
    init: ->
      @items = []

      # Provide a way for the value to be reset to [undefined]
      # NB: This is used by the data-binder.
      @ctrl.value.delete = =>
          if item = @helpers.itemFromValue(undefined)
            # Select the item that has an 'undefined' value.
            @helpers.select(item)
          else
            # Deselect all radios.
            @helpers.unselect()


    ready: ->
      # Keep the visual state in sync.
      @autorun => @helpers.updateState()

      # UP/DOWN keyboard events.
      @__internal__.keyHandle = Util.keyboard.keyDown (e) =>
          if @ctrl.hasFocus()
            @api.selectPrevious() if e.is.up
            @api.selectNext() if e.is.down


    destroyed: ->
      @__internal__.keyHandle?.dispose()
      @__internal__.binder?.dispose()



    api:
      isEnabled: (value) -> @prop 'isEnabled', value, default:true
      size:      (value) -> @prop 'size', value, default:22
      count:     (value) -> @prop 'count', value, default:0


      ###
      REACTIVE: Gets or sets the currently selected value.
      ###
      value: (value) ->
        # Write.
        if value isnt undefined
          @helpers.select(@helpers.itemFromValue(value))

        # Read.
        @api.selectedItem()?.value


      ###
      Gets the selected item.
      ###
      selectedItem: -> @helpers.selectedItem()?.api


      ###
      REACTIVE: Gets the set of radio buttons.
      ###
      items: ->
        @api.count() # Hook into reactive callback.
        @items.map (item) -> item.api


      ###
      Assigns focus to the first radio button.
      ###
      focus: ->
        if not @ctrl.hasFocus()
          item = @api.selectedItem() ? @api.items().first()
          item?.focus()


      ###
      Moves selection to the next radio button.
      ###
      selectNext: ->
        items = @api.items()
        return if items.length is 0
        selectedItem = @helpers.selectedItem()
        index = selectedItem?.api.index() ? -1
        index += 1
        index = items.length - 1 if index >= items.length
        @api.select(index)
        if selectedItem?.ctrl.hasFocus()
          items[index].focus()


      ###
      Moves selection to the previous radio button.
      ###
      selectPrevious: ->
        items = @api.items()
        return if items.length is 0
        selectedItem = @helpers.selectedItem()
        index = selectedItem?.api.index() ? items.length
        index -= 1
        index = 0 if index < 0
        @api.select(index)
        if selectedItem?.ctrl.hasFocus()
          items[index].focus()


      ###
      Selects the first radio button.
      ###
      selectFirst: -> @api.items().first()?.select()



      ###
      Selects the last radio button.
      ###
      selectLast: -> @api.items().last()?.select()


      ###
      Selects the given index.
      @param index: The index to select.
      ###
      select: (index) -> @helpers.select(@items[index])


      # ----------------------------------------------------------------------


      ###
      See [Ctrls.DataBinder].
      ###
      bind: (propertyName, modelFactory) ->
        @__internal__.binder?.dispose()
        @__internal__.binder = new Ctrls.DataBinder(@ctrl, 'value', propertyName, modelFactory)


      # ----------------------------------------------------------------------


      ###
      Adds a new radio button to the set.
      @param options:
                - id          Optional
                - value       Optional
                - label       Optional
                - message     Optional
                - isChecked   Optional
                - isEnabled   Optional
      ###
      add: (options = {}) ->
        item = createItem(@, options)
        @items.push(item)
        @api.count(@items.length)

        # Set initial selection state.
        isChecked = options.isChecked
        isChecked = true if not @helpers.selectedItem()? and options.value is undefined
        item.api.select() if isChecked


      ###
      Removes the radio button at the specified index.
      @param index: The index of the radio button to remove.
      ###
      removeAt: (index) ->
        if item = @items[index]
          item.ctrl.dispose()
          @items.removeAt(index)
          @api.count(@items.length)



      ###
      Clears all radio buttons.
      ###
      clear: -> item.remove() for item in @api.items()




    helpers:
      selectedItem: (value) -> @prop 'selectedItem', value

      select: (item) ->
        return if @helpers.selectedItem() is item
        @helpers.selectedItem(item)
        @helpers.updateState()

        # Alert listeners of changes.
        value = @api.value()
        @trigger('changed', { value:value })
        @__internal__.binder?.onCtrlChanged(value)


      unselect: ->
        if item = @helpers.selectedItem()
          item.api.isChecked(false)
        @helpers.selectedItem(null)



      items: ->
        @api.count() # Hook into reactive callback.
        @items


      itemFromValue: (value) ->
        for item in @items
          return item if item.api.value is value
        null


      cssClass: ->
        isEnabled = @api.isEnabled()
        css = "c-size-#{ @api.size() }"
        css += ' c-enabled' if isEnabled
        css += ' c-disabled' if not isEnabled
        css


      updateState: ->
        return if @__internal__.isUpdatingState
        @__internal__.isUpdatingState = true

        isEnabled = @api.isEnabled()
        size = @api.size()
        selectedItem = Deps.nonreactive => @helpers.selectedItem()

        isItemEnabled = (item) ->
            return false unless isEnabled
            item.api.isEnabled()

        for item in @items.compact()
          radioCtrl = item.ctrl
          radioCtrl.size(size)
          radioCtrl.isChecked((item.id is selectedItem?.id) ? false)
          radioCtrl.isEnabled(isItemEnabled(item))

        @__internal__.isUpdatingState = false




# ----------------------------------------------------------------------



createItem = (instance, options) ->
  id = options.id ? _.uniqueId('rdo')
  ctrl = null
  defaultIsEnabled = options.isEnabled ? true
  helpers = instance.helpers

  # Render the radio button.
  data =
    label:      options.label ? 'Unnamed'
    message:    options.message
    size:       instance.api.size()
    isEnabled:  defaultIsEnabled
    value:      options.value
  ctrl = instance.appendCtrl 'c-radio', instance.el(), data:data
  ctrl.onDestroyed ->
      # Dispose.
      ctrl.off 'changed'
      helpers.selectedItem(null) if helpers.selectedItem() is item


  item =
    id: id
    ctrl: ctrl
    api:
      id:id
      value: options.value
      index: -> instance.items.indexOf(item)
      focus: -> ctrl.focus()
      remove: -> instance.api.removeAt(@index())
      select: -> item.api.isChecked(true)
      isChecked: (value) -> ctrl?.isChecked(value)
      isEnabled: (value) -> instance.prop "isEnabled:#{ id }", value, default:defaultIsEnabled

  # Monitor selection state.
  ctrl.on 'changed', (j, e) -> helpers.select(item) if e.isChecked

  # Finish up.
  item





