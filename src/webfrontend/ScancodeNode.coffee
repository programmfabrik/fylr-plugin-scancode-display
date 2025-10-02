class ez5.PdfCreator.Node.Scancode extends ez5.PdfCreator.Node

    @getName: ->
        "scancode"

    __renderPdfContent: (opts) ->
        object = opts.object
        if not object
            return

        data = @getData()
        if not data.field_name
            return

        fieldNameSplit = data.field_name.split(".")
        scancodeData = null
        getData = (_data, fieldNames) =>
            name = fieldNames[0]
            value = _data[name]
            if CUI.util.isString(value)
                scancodeData = value
                return

            fieldNames = fieldNames.slice(1)
            if CUI.util.isPlainObject(value)
                getData(value, fieldNames)
            return
        getData(object, fieldNameSplit)

        fieldName = fieldNameSplit[0]
        if fieldName in ['_uuid', '_system_object_id', '_global_object_id']
            _data = opts.object
            scancodeData = _data[fieldName]
        if fieldNameSplit.length > 1
            if fieldNameSplit[1] == '_uuid'
                scancodeData = opts.object._uuid  

        # add prefix and suffix if given
        if @.opts?.data?.code_prefix
            scancodeData = @.opts.data.code_prefix + scancodeData
        if @.opts?.data?.code_suffix
            scancodeData = scancodeData + @.opts.data.code_suffix

        if not scancodeData
            return

        scancode = new ez5.Scancode
            mode: "pdf"
            type: data.code_type
            scancode_type: data.scancode_type
            download: false

        scancode.render(scancodeData)

        scancodeWidth = data.scancode_width or "100%"
        img = CUI.dom.findElement(scancode.DOM, "img")
        CUI.dom.setStyle(img, width: scancodeWidth)
        return img

    __getSettingsFields: ->
        idObjecttype = @__getIdObjecttype()
        fields = ez5.ScancodeMaskSplitter.getScancodeOptions(idObjecttype, false
            store_value: "fullname"
            filter: (field) ->
                return not field.insideNested()
        )
        fields.push(
            type: CUI.Input
            name: "scancode_width"
            form: label: $$("pdf-creator.settings.scancode.scancode-width|text")
            placeholder: $$("pdf-creator.settings.scancode.scancode-width|placeholder")
        )
        return fields

    __getStyleSettings: ->
        return ["class-name", "background", "width", "height", "border", "position-absolute", "display", "top", "left", "right", "bottom", "margin-top", "margin-left", "margin-right", "margin-bottom", "padding-top", "padding-left", "padding-right", "padding-bottom"]

ez5.PdfCreator.plugins.registerPlugin(ez5.PdfCreator.Node.Scancode)
