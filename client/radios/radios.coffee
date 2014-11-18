###
A set of radio buttons.

###
Ctrl.define
  'c-radios':
    init: -> @items = []

    ready: ->
      @autorun => @helpers.updateState()


    api:
      isEnabled: (value) -> @prop 'isEnabled', value, default:true
      size:      (value) -> @prop 'size', value, default:22
      count:     (value) -> @prop 'count', value, default:0

      ###
      Gets or sets the currently selected value.
      ###
      value: (value) ->
        # Write.
        if value isnt undefined
          @helpers.selectedItem(@helpers.itemFromValue(value))

        # Read.
        @helpers.selectedItem()?.api.value



      items: ->
        @api.count() # Hook into reactive callback.
        @items.map (item) -> item.api


      focus: -> @api.items().first()?.focus()



      ###
      Adds a new radio button to the set.
      @param options:
                - id:       Optional
                - value:    Optional
                - label:    Optional
                - message:  Optional
      ###
      add: (options = {}) ->
        item = createItem(@, options)
        @items.push(item)
        @api.count(@items.length)



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
        isEnabled = @api.isEnabled()
        size = @api.size()
        selectedItem = @helpers.selectedItem()

        for item in @items
          radioCtrl = item.ctrl
          radioCtrl.isEnabled(isEnabled)
          radioCtrl.size(size)
          radioCtrl.isChecked((item.id is selectedItem?.id) ? false)





# ----------------------------------------------------------------------



createItem = (instance, options) ->
  id = options.id ? _.uniqueId('rdo')
  ctrl = null

  # Render the radio button.
  data =
    label:    options.label ? 'Unnamed'
    message:  options.message
    size:     instance.api.size()
  ctrl = instance.appendCtrl 'c-radio', instance.el(), data:data
  ctrl.onDestroyed -> handle?.stop()

  item =
    id: id
    ctrl: ctrl
    api:
      id:id
      value: options.value
      index: -> instance.items.indexOf(item)
      isChecked: -> ctrl?.isChecked()
      focus: -> ctrl.focus()
      remove: -> instance.api.removeAt(@index())


  # Monitor selection state.
  handle = Deps.autorun ->
      if ctrl.isChecked()
        instance.helpers.selectedItem(item)

  # Finish up.
  item





