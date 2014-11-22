sizeMap =
  'c-size-50': 'c-btn-large'
  'c-size-32': 'c-btn'
  'c-size-28': 'c-btn-small'
  'c-size-22': 'c-btn-mini'


###
A standard button.

Events:
  - clicked

###
Ctrl.define
  'c-button':
    init: ->
      throwUnlessSupported = (attr, value, supportedValues) =>
          unless (supportedValues.any (item) -> item is value)
            throw new Error("#{ attr } '#{ value }' not supported. Use one of: #{ supportedValues }")

      @autorun => throwUnlessSupported('size', @api.size(), [50, 32, 28, 22])
      @autorun => throwUnlessSupported('color', @api.color(), ['silver', 'blue', 'green', 'red', 'orange', 'black', null])



    api:
      isEnabled: (value) -> @prop 'isEnabled', value, default:true
      size:      (value) -> @prop 'size', value, default:32
      label:     (value) -> @prop 'label', value
      color:     (value) -> @prop 'color', value, default:'silver'
      isPressed: (value) -> @prop 'isPressed', value, default:false


      ###
      Invokes the click operation if enabled.
      ###
      click: -> @helpers.fire('clicked') if @api.isEnabled()





    helpers:
      cssClass: ->
        isEnabled = @api.isEnabled()
        cssSize = "c-size-#{ @api.size() }"
        cssBtn = sizeMap[cssSize]

        color = @api.color()
        color = '' if color is 'silver'
        color = 'label-only' if color is null
        color = "c-#{ color }" unless color is ''

        css = "#{ cssSize } #{ cssBtn } #{ color }"
        css += ' c-enabled' if isEnabled
        css += ' c-disabled' if not isEnabled

        css

      disabled: -> 'disabled' unless @api.isEnabled()

      label: ->
        label = @api.label()
        return if label is null
        label = 'Unnamed' if Util.isBlank(label)
        label

      fire: (event) -> @trigger(event, { label:@api.label() })

      onClick: (isPressed) ->
        if @api.isEnabled()
          @api.isPressed(isPressed)
          @api.click() if isPressed is false




    events:
      'mousedown': (e) -> @helpers.onClick(true) if e.button is 0
      'mouseup': (e) -> @helpers.onClick(false) if e.button is 0
