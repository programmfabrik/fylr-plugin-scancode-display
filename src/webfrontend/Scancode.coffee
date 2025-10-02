class ez5.Barcode extends CUI.DOMElement

    @TYPE_QR = "QR code"
    @TYPE_BAR = "Barcode"

    @DEFAULT_BARCODE_TYPE = "CODE128"

    initOpts: ->
        super()
        @addOpts
            type:
                check: [ez5.Barcode.TYPE_BAR, ez5.Barcode.TYPE_QR]
                default: ez5.Barcode.TYPE_BAR
            barcode_type:
                check: String
                default: ez5.Barcode.DEFAULT_BARCODE_TYPE
            mode:
                check: String
            download:
                check: Boolean
				default: false

    constructor: (opts) ->
        super(opts)

        @registerDOMElement(CUI.dom.div())
        @__ratio = CUI.dom.div("cui-scancode-ratio")
        CUI.dom.append(@DOM, @__ratio)
        return @

    render: (data, { displayName = "", fieldName, objectType } = {}) ->        
        isQR = @_type == ez5.Barcode.TYPE_QR
        if isQR
            @addClass("cui-scancode--square")

        if not data or not (CUI.util.isString(data) or CUI.util.isNumber(data))
            if @_mode == "editor"
                @__replaceWithLabel("scancode.label.empty-data.#{@__getLocaType()}", displayName)
                return @
            CUI.dom.empty(@__ratio) # No data, other mode than editor, remove the barcode.
            return @

        try
            if isQR
                data = data.toString()
                if data.length >= 1056 # More than 1056 the library throws an error.
                    @__replaceWithLabel("scancode.label.qr-data-too-long")
                    return @

                element = CUI.dom.div()
                new QRCode(element, data)

                img = CUI.dom.findElement(element, "img")
                CUI.dom.remove(img)
                canvas = CUI.dom.findElement(element, "canvas")
            else
                canvas = CUI.dom.$element("canvas")
                JsBarcode(canvas, data,
                    format: @_barcode_type
                )
        catch
            @__replaceWithLabel("scancode.label.wrong-data.#{@__getLocaType()}")
            return @

        url = canvas.toDataURL()
        img = CUI.dom.element("img", src: url)

        if @_mode != "pdf" && @_download
            fileName = "
                #{objectType}
                -
                #{fieldName}
                -
                #{@_type}#{if @_type == ez5.Barcode.TYPE_BAR then " #{@_barcode_type}" else ""}
            "
            downloadLink = CUI.dom.element("a", { href: url, download: fileName })
            downloadButton = new CUI.Button
                text: $$("scancode.download|text")
                icon: $$("scancode.download|icon")
            element = CUI.dom.element("div")

            CUI.dom.append(downloadLink, downloadButton)
            CUI.dom.append(@DOM, downloadLink)

        CUI.dom.replace(@__ratio, img)
        return @

    __replaceWithLabel: (locaKey, arg) ->
        label = new CUI.Label(text: $$(locaKey, arg: arg), centered: true, appearance: "secondary", size: "mini", multiline: true)
        CUI.dom.replace(@__ratio, label)
        return

    __getLocaType: ->
        return @_type.replace(/\s/g, "_").toLowerCase()
