Ctrl.define
  'c-select':
    init: ->
    ready: ->
    destroyed: ->
    model: ->
    api: 
      isEnabled: (value) -> @prop 'isEnabled', value, default:true
      
    helpers: {}
    events: {}
