Ctrl.define
  'c-button':
    init: ->
    ready: ->
    destroyed: ->
    model: ->
    api:
      ###
      Gets or sets the enabled state of the control.
      ###
      isEnabled: (value) -> @prop 'isEnabled', value, default:true

    helpers: {}
    events: {}
