{View} = require 'atom'

module.exports =
class SmartTagCycleView extends View
  @content: ->
    @div class: 'smart-tag-cycle overlay from-top', =>
      @div "The SmartTagCycle package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "smart-tag-cycle:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "SmartTagCycleView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
