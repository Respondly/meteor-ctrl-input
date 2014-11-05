###
Binds changes between a model and a UI control.
###
class Ctrls.DataBinder extends AutoRun
  ###
  Constructor.
  @param ctrlProp(value): The reactive property for the control to bind to.
  @param propertyName:    Name of the property-function.
  @param modelFactory:    Function that retrieves the model.
  ###
  constructor: (@ctrlProp, @propertyName, @modelFactory) ->
    super

    syncCtrlWithModel = =>
          if model = @model()
            to = model.changes()?[@propertyName]?.to ? @modelProp()
            from = Deps.nonreactive => @ctrlProp()
            if to isnt from
              @ctrlProp(to) unless @ctrlProp() is to

    # SYNC: Update the UI control when the saved model property is updated.
    @autorun => syncCtrlWithModel()

    # SYNC: Model reverts.
    @autorun =>
          if model = @model()
            if model.isSubModel() and model.parentModel?
              # NB: Hook into parent model if this is a sub-model.
              #     This ensures reactive changes invoke the callback.
              model = model.parentModel

            if model.changes() is null
              # The changes have been reset, sync the control.
              syncCtrlWithModel()



  ###
  The model being synced.
  ###
  model: -> @modelFactory()


  ###
  The read/write property function on the model.
  ###
  modelProp: (value) -> @model()[@propertyName](value)


  ###
  Invoked by the UI control when it's value changes.
  @param toValue: The new value that the control has changed to.
  ###
  onCtrlChanged: (toValue) ->
    # Update the model when the UI control changes.
    @modelProp(toValue)

