{WorkspaceView} = require 'atom'
SmartTagCycle = require '../lib/smart-tag-cycle'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "SmartTagCycle", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('smart-tag-cycle')

  describe "when the smart-tag-cycle:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.smart-tag-cycle')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'smart-tag-cycle:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.smart-tag-cycle')).toExist()
        atom.workspaceView.trigger 'smart-tag-cycle:toggle'
        expect(atom.workspaceView.find('.smart-tag-cycle')).not.toExist()
