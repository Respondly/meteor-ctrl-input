sizeMap =
  'c-size-50': 'btn-large'
  'c-size-32': 'btn'
  'c-size-28': 'btn-small'
  'c-size-22': 'btn-mini'


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

    ready: ->
    destroyed: ->
    model: ->
    api:
      isEnabled: (value) -> @prop 'isEnabled', value, default:true
      size:      (value) -> @prop 'size', value, default:32
      label:     (value) -> @prop 'label', value, default:'Unnamed'
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

        css = "#{ cssSize } #{ cssBtn } #{ color }"
        css += ' c-enabled' if isEnabled
        css += ' c-disabled' if not isEnabled
        css

      disabled: -> 'disabled' unless @api.isEnabled()

      fire: (event) -> @trigger(event, { label:@api.label() })

      onClick: (isPressed) ->
        if @api.isEnabled()
          @api.isPressed(isPressed)
          @api.click() if isPressed is false



    events:
      'mousedown': (e) -> @helpers.onClick(true) if e.button is 0
      'mouseup': (e) -> @helpers.onClick(false) if e.button is 0
