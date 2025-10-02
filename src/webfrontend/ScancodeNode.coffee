class ez5.PdfCreator.Node.Barcode extends ez5.PdfCreator.Node

    @getName: ->
        "barcode"

    __renderPdfContent: (opts) ->
        object = opts.object
        if not object
            return

        data = @getData()
        if not data.field_name
            return

        fieldNameSplit = data.field_name.split(".")
        barcodeData = null
        getData = (_data, fieldNames) =>
            name = fieldNames[0]
            value = _data[name]
            if CUI.util.isString(value)
                barcodeData = value
                return

            fieldNames = fieldNames.slice(1)
            if CUI.util.isPlainObject(value)
                getData(value, fieldNames)
            return
        getData(object, fieldNameSplit)

        fieldName = fieldNameSplit[0]
        if fieldName in ['_uuid', '_system_object_id', '_global_object_id']
            _data = opts.object
            barcodeData = _data[fieldName]
        if fieldNameSplit.length > 1
            if fieldNameSplit[1] == '_uuid'
                barcodeData = opts.object._uuid  

        # add prefix and suffix if given
        if @.opts?.data?.code_prefix
            barcodeData = @.opts.data.code_prefix + barcodeData
        if @.opts?.data?.code_suffix
            barcodeData = barcodeData + @.opts.data.code_suffix

        if not barcodeData
            return

        barcode = new ez5.Barcode
            mode: "pdf"
            type: data.code_type
            barcode_type: data.barcode_type
            download: false

        barcode.render(barcodeData)

        barcodeWidth = data.barcode_width or "100%"
        img = CUI.dom.findElement(barcode.DOM, "img")
        CUI.dom.setStyle(img, width: barcodeWidth)
        return img

    __getSettingsFields: ->
        idObjecttype = @__getIdObjecttype()
        fields = ez5.BarcodeMaskSplitter.getBarcodeOptions(idObjecttype, false
            store_value: "fullname"
            filter: (field) ->
                return not field.insideNested()
        )
        fields.push(
            type: CUI.Input
            name: "barcode_width"
            form: label: $$("pdf-creator.settings.scancode.scancode-width|text")
            placeholder: $$("pdf-creator.settings.scancode.scancode-width|placeholder")
        )
        return fields

    __getStyleSettings: ->
        return ["class-name", "background", "width", "height", "border", "position-absolute", "display", "top", "left", "right", "bottom", "margin-top", "margin-left", "margin-right", "margin-bottom", "padding-top", "padding-left", "padding-right", "padding-bottom"]

ez5.PdfCreator.plugins.registerPlugin(ez5.PdfCreator.Node.Barcode)
