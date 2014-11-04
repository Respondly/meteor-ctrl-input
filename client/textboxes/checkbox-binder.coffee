###
Binds changes between a model and a checkbox.
###
class Ctrls.CheckboxBinder extends AutoRun
  ###
  Constructor.
  @param checkboxCtrl:  The checkbox control.
  @param propertyName:  Name of the property-function.
  @param modelFactory:  Function that retrieves the model.
  @param options
            - checkboxChanged(e): Event function for modifying or cancelling changes.
            - modelChanged(e):    Event function for modifying or cancelling changes.
  ###
  constructor: (@checkboxCtrl, @propertyName, @modelFactory, options = {}) ->
    super
    @_onCheckboxChanged = new Handlers(@)
    @_onModelChanged = new Handlers(@)

    @onCheckboxChanged(options.checkboxChanged)
    @onModelChanged(options.modelChanged)

    # SYNC: Update the model when the checkbox changes.
    @checkboxCtrl.on 'changed', (j,e) =>
          to = e.isChecked
          from = @prop()
          result = @_onCheckboxChanged.invoke({ to:to, from:from })
          if result
            @prop(to)


    # SYNC: Update the checkbox when the saved model property is updated.
    @autorun =>
          return if @isDisposed
          if model = @model()
            to = model.changes()?[@propertyName]?.to ? @prop()
            from = Deps.nonreactive => @checkboxCtrl.isChecked()
            return if to is from

            result = @_onModelChanged.invoke({ to:to, from:from })
            if result
              Deps.nonreactive =>
                @checkboxCtrl.isChecked(to)



  disopse: ->
    super
    @_onCheckboxChanged.dispose()
    @_onModelChanged.dispose()

  model: -> @modelFactory()
  prop: (value) -> @model()[@propertyName](value)

  onCheckboxChanged: (func) -> @_onCheckboxChanged.push(func)
  onModelChanged: (func) -> @_onModelChanged.push(func)


