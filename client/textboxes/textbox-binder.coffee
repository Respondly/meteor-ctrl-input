###
Binds changes between a model and a textbox.
###
class Ctrls.TextboxBinder extends AutoRun
  ###
  Constructor.
  @param textboxCtrl:  The textbox control.
  @param propertyName: Name of the property-function.
  @param modelFactory: Function that retrieves the model.
  @param options
            - format:             The content format:
                                        - 'html'
                                        - 'text' (default)
  ###
  constructor: (@textboxCtrl, @propertyName, @modelFactory, options = {}) ->
    super
    format = options.format ? 'text'

    # SYNC: Update the model when the textbox changes.
    @textboxCtrl.on 'changed', (j,e) =>
          to = e[format]
          from = @prop()
          @prop(to)



    syncTextboxWithModel = =>
          if model = @model()
            to = model.changes()?[@propertyName]?.to ? @prop()
            from = Deps.nonreactive => @textboxCtrl.text()
            if to isnt from
              @textboxCtrl.text(to) unless @textboxCtrl.text() is to


    # SYNC: Update the textbox when the saved model property is updated.
    @autorun => syncTextboxWithModel()


    # SYNC: Model reverts.
    @autorun =>
      if model = @model()
        if model.isSubModel() and model.parentModel?
          model = model.parentModel() # NB: Hook into parent model, this ensures
                                      #     reactive changes invoke the callback.
        syncTextboxWithModel() if model.changes() is null




  model: -> @modelFactory()
  prop: (value) -> @model()[@propertyName](value)

