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


    ready: ->
    destroyed: ->
    model: ->
    api:
      isEnabled: (value) -> @prop 'isEnabled', value, default:true
      size:      (value) -> @prop 'size', value, default:32
      count:     (value) -> @prop 'count', value, default:0


      ###
      REACTIVE: Gets the set of select options.
      ###
      items: ->
        @api.count() # Hook into reactive callback.
        @items.map (item) -> item.api


      ###
      REACTIVE: Gets the currently selected value.
      ###
      value: (value) -> @prop 'value', value




    helpers:
      cssClass: ->
        isEnabled = @api.isEnabled()
        css = "c-size-#{ @api.size() }"
        css += ' c-enabled' if isEnabled
        css += ' c-disabled' if not isEnabled
        css

    events: {}
