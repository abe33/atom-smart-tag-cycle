{WorkspaceView} = require 'atom'
SmartTagCycle = require '../lib/smart-tag-cycle'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "SmartTagCycle", ->
  [activationPromise, editorView, editor] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    waitsForPromise ->
        atom.workspaceView.open('sample.erb')

    runs ->
      editorView = atom.workspaceView.getActiveView()
      editor = editorView.getEditor()

      activationPromise = atom.packages.activatePackage('smart-tag-cycle')

  describe "when the smart-tag-cycle:erb command is triggered", ->

    describe "with the cursor outside of a target tag", ->
      beforeEach ->
        runs ->
          editorView.setText("""
          <html>
            <head>
            </head>
            <body>
              <%= yield %>
            </body>
          </html>
          """)
          editor.setCursorBufferPosition([1,8])

      it 'inserts the corresponding tag', ->
        waitsForPromise -> activationPromise

        runs ->
          editorView.trigger 'smart-tag-cycle:erb'

          expect(editor.lineForBufferRow(1)).toEqual("  <head><% %>")
          expect(editor.getCursorBufferPosition()).toEqual([1,10])

    describe 'with the cursor inside a match', ->
      beforeEach ->
        runs ->
          editorView.setText("""
          <html>
            <head>
              <% %>
            </head>
            <body>
              <%= yield %>
            </body>
          </html>
          """)
          editor.setCursorBufferPosition([2,6])

      it 'cycle to the next match', ->
        waitsForPromise -> activationPromise

        runs ->
          editorView.trigger 'smart-tag-cycle:erb'
          expect(editor.lineForBufferRow(2)).toEqual("    <% %>")
          expect(editor.getCursorBufferPosition()).toEqual([5,6])
