###
A <select> control.

Events:
  - changed

###
Ctrl.define
  'c-select':
    init: ->
      @items = []
      @autorun =>
          # Size.
          supportedSizes = [32]
          size = @api.size()
          unless (supportedSizes.any (item) -> item is size)
            throw new Error("Size '#{ size }' not supported. Use one of: #{ supportedSizes }")


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


    destroyed: ->
      @__internal__.binder?.dispose()



    api:
      isEnabled: (value) -> @prop 'isEnabled', value, default:true
      size:      (value) -> @prop 'size', value, default:32
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
      REACTIVE: Gets the set of select options.
      ###
      items: ->
        @api.count() # Hook into reactive callback.
        @items.map (item) -> item.api


      # ----------------------------------------------------------------------


      ###
      Adds a new <option> to the set.
      @param options:
                - id          Optional
                - value       Optional
                - label       Optional
                - isSelected  Optional
      ###
      add: (options = {}) ->
        item = createItem(@, options)
        @items.push(item)
        @api.count(@items.length)

        # Set initial selection state.
        isSelected = options.isSelected
        isSelected = true if not @helpers.selectedItem()?
        item.api.select() if isSelected


      ###
      Removes the <option> button at the specified index.
      @param index: The index of the <option> button to remove.
      ###
      removeAt: (index) ->
        if item = @items[index]
          item.ctrl.dispose()
          @items.removeAt(index)
          @api.count(@items.length)



      ###
      Clears all <option>'s.
      ###
      clear: -> item.remove() for item in @api.items()


      # ----------------------------------------------------------------------


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





    helpers:
      disabled: -> 'disabled' unless @api.isEnabled()

      cssClass: ->
        isEnabled = @api.isEnabled()
        css = "c-size-#{ @api.size() }"
        css += ' c-enabled' if isEnabled
        css += ' c-disabled' if not isEnabled
        css

      selectedItem: (value) -> @prop 'selectedItem', value

      select: (item) ->
        item = @items[0] if not item?
        return if @helpers.selectedItem() is item
        @helpers.selectedItem(item)
        @helpers.updateState()

        # Alert listeners of changes.
        value = @api.value()
        @trigger('changed', { value:value, item:item?.api })
        @__internal__.binder?.onCtrlChanged(value)


      unselect: ->
        if item = @helpers.selectedItem()
          item.api.isSelected(false)
        @helpers.selectedItem(null)


      items: ->
        @api.count() # Hook into reactive callback.
        @items


      itemFromValue: (value) ->
        for item in @items
          return item if item.api.value is value
        null


      itemFromId: (id) -> @items.find (item) -> item.id is id




      updateState: ->
        return if @__internal__.isUpdatingState
        @__internal__.isUpdatingState = true

        selectedItem = Deps.nonreactive => @helpers.selectedItem()

        for item in @items.compact()
          itemCtrl = item.ctrl
          itemCtrl.isSelected((item.id is selectedItem?.id) ? false)

        @__internal__.isUpdatingState = false



    events:
      'change': (e) ->
        value = @el().val()
        value = null if value is '<null>'
        value = undefined if value is '<undefined>'
        if value is undefined
          @ctrl.value.delete()
        else
          @api.value(value)



# ----------------------------------------------------------------------


createItem = (instance, options) ->
  id = options.id ? _.uniqueId('option')
  ctrl = null
  helpers = instance.helpers

  # Render the <option>.
  data =
    id:         id
    label:      options.label
    value:      options.value
  ctrl = instance.appendCtrl 'c-select-option', instance.el(), data:data
  ctrl.onDestroyed ->
      # Dispose.
      ctrl.off 'changed'
      helpers.selectedItem(null) if helpers.selectedItem() is item


  item =
    id: id
    ctrl: ctrl
    api:
      id:id
      value: data.value
      index: -> instance.items.indexOf(item)
      focus: -> instance.ctrl.focus()
      remove: -> instance.api.removeAt(@index())
      select: -> instance.helpers.select(item)
      isSelected: (value) -> ctrl?.isSelected(value)

  # Finish up.
  item





