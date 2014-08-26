###
Binds changes between a model and a textbox.
###
class Ctrls.TextboxBinder extends AutoRun
  ###
  Constructor.
  @param textboxCtrl:  The textbox control.
  @param propertyName: Name of the property-function.
  @param modelFactory: Function that retrieves the model
  @param options
            - textboxChanged(e):  Event function for modifying or cancelling changes.
            - modelChanged(e):    Event function for modifying or cancelling changes.
            - format:             The content format:
                                        - 'html'
                                        - 'text' (default)
  ###
  constructor: (@textboxCtrl, @propertyName, @modelFactory, options = {}) ->
    super
    format = options.format ? 'text'
    @_onTextboxChanged = new Handlers(@)
    @_onModelChanged   = new Handlers(@)

    @onTextboxChanged(options.textboxChanged)
    @onModelChanged(options.modelChanged)

    # SYNC: Update the model when the textbox changes.
    @textboxCtrl.on 'changed', (j,e) =>
          to = e[format]
          from = @prop()

          result = @_onTextboxChanged.invoke({ to:to, from:from })
          if result
            @prop(to)

    # SYNC: Update the textbox when the saved model property is updated.
    @autorun =>
          return if @isDisposed
          if model = @model()
            to = model.changes()?[@propertyName]?.to ? @prop()
            from = Deps.nonreactive => @textboxCtrl.text()
            return if to is from

            result = @_onModelChanged.invoke({ to:to, from:from })
            if result
              Deps.nonreactive =>
                @textboxCtrl.text(to)



  disopse: ->
    super
    @_onTextboxChanged.dispose()
    @_onModelChanged.dispose()

  model: -> @modelFactory()
  prop: (value) -> @model()[@propertyName](value)

  onTextboxChanged: (func) -> @_onTextboxChanged.push(func)
  onModelChanged: (func) -> @_onModelChanged.push(func)
