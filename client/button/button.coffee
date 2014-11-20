Ctrl.define
  'c-button':
    init: ->
      @autorun =>
          # Size.
          supportedSizes = [50, 32, 28, 22]
          size = @api.size()
          unless (supportedSizes.any (item) -> item is size)
            throw new Error("Size '#{ size }' not supported. Use one of: #{ supportedSizes }")

    ready: ->
    destroyed: ->
    model: ->
    api:
      isEnabled: (value) -> @prop 'isEnabled', value, default:true
      size:      (value) -> @prop 'size', value, default:32

    helpers: 
      cssClass: ->
        isEnabled = @api.isEnabled()
        css = "c-size-#{ @api.size() }"
        css += ' c-enabled' if isEnabled
        css += ' c-disabled' if not isEnabled
        css

    events: {}
