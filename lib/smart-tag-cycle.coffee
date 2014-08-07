SmartTagCycleView = require './smart-tag-cycle-view'

module.exports =
  smartTagCycleView: null

  activate: (state) ->
    @smartTagCycleView = new SmartTagCycleView(state.smartTagCycleViewState)

  deactivate: ->
    @smartTagCycleView.destroy()

  serialize: ->
    smartTagCycleViewState: @smartTagCycleView.serialize()
