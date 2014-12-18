Ctrl.define
  'c-checkbox-switch':
    init: ->
      # Ensure size is supported.
      @autorun =>
          supportedSizes = [22, 34]
          size = @api.size()
          unless (supportedSizes.any (item) -> item is size)
            throw new Error("Size '#{ size }' not supported. Use one of: #{ supportedSizes }")

      # Only allow animations after load is complete
      # to avoid a slide occuring on first display.
      Util.delay => @el().addClass('c-animated')


    api:
      isEnabled: (value) -> @prop 'enabled', value, default:true
      isChecked: (value) -> @prop 'isChecked', value, default:true
      size:      (value) -> @prop 'size', value, default:22


    helpers:
      # cssClass: (value) -> @prop 'cssClass', value
      cssClass: ->
        isChecked = @api.isChecked()
        isEnabled = @api.isEnabled()
        size      = @api.size()
        css = ''
        css += ' c-indeterminate' if (isChecked is null)
        css += ' c-checked' if (isChecked is true or isChecked is null)
        css += ' c-not-checked' if (isChecked is false)
        css += ' c-enabled' if isEnabled
        css += ' c-disabled' if not isEnabled
        css += " c-size-#{ size }"
        css


