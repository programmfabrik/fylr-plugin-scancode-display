class ez5.ScancodeEditorPlugin extends ez5.EditorPlugin
	checkForm: (opts) ->
		data = opts.resultObject.getData()[opts.resultObject.objecttype()]

		findScancodes = (_data) ->
			for key, value of _data
				if CUI.util.isArray(value) # Nested values.
					for _value in value
						findScancodes(_value)
					continue

				if not key.endsWith(":scancode") or value not instanceof ez5.Barcode
					continue

				_key = key.split(":scancode")[0]
				value.render(_data[_key])
		findScancodes(data)

		return []

ez5.session_ready ->
	Editor.plugins.registerPlugin(ez5.ScancodeEditorPlugin)
