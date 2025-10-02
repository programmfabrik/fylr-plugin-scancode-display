class ez5.ScancodeMaskSplitter extends CustomMaskSplitter

    isSimpleSplit: ->
        return true

    renderAsField: ->
        return true

    getOptions: ->
        fieldSelectorOpts =
            store_value: "name"
            filter: (field) =>
                if not @father.children.some((_field) => _field.getData().field_name == field.name())
                    return false
                return true
        fields = ez5.ScancodeMaskSplitter.getScancodeOptions(@maskEditor.getMask().getTable().table_id, true, fieldSelectorOpts)
        fields.push
            type: CUI.NumberInput
            form: label: $$("scancode.custom.splitter.options.expert_search_limit.label")
            name: "expert_search_limit"
            decimals: 0
        return fields

    @getScancodeOptions: (idObjecttype, showDownloadOptions, fieldSelectorOptions = {}) ->
        disableEnableScancodeType = (field) ->
            form = field.getForm()
            data = form.getData()
            scancodeTypeField = form.getFieldsByName("scancode_type")[0]
            if data.code_type == ez5.Scancode.TYPE_BAR
                scancodeTypeField.enable()
            else
                scancodeTypeField.disable()
            return

        fieldSelectorFilter = fieldSelectorOptions.filter

        fieldSelector = new ez5.FieldSelector
            form: label: $$("scancode.custom.splitter.options.field-selector.label")
            name: "field_name"
            store_value: fieldSelectorOptions.store_value or "name"
            placeholder: $$("scancode.custom.splitter.options.field-selector.placeholder")
            objecttype_id: idObjecttype
            schema: "HEAD"
            filter: (field) =>

                # allow uuid, systemobjectid and globalobjectid
                if field.isTopLevelField()
                    if field instanceof SystemObjectIdColumn or 
                        field instanceof UuidColumn
                            return true

                if fieldSelectorFilter and not fieldSelectorFilter?(field)
                    return false

                return field instanceof TextColumn and
                    field not instanceof DecimalColumn and
                    field not instanceof LinkColumn and
                    field not instanceof PrimaryKeyColumn and
                    field not instanceof LocaTextColumn and
                    field not instanceof TextMultiColumn and
                    not field.isTopLevelField()

        fields = 
        [
            type: CUI.Select
            name: "code_type"
            form: label: $$("scancode.custom.splitter.options.code-type.label")
            options: [
                text: $$("scancode.custom.splitter.options.code-type.scancode.text")
                value: ez5.Scancode.TYPE_BAR
            ,
                text: $$("scancode.custom.splitter.options.code-type.qrcode.text")
                value: ez5.Scancode.TYPE_QR
            ]
            onDataChanged: (_, field) ->
                disableEnableScancodeType(field)
        ,
            type: CUI.Select
            name: "scancode_type"
            form:
                label: $$("scancode.custom.splitter.options.scancode-type.label")
                hint: $$("scancode.custom.splitter.options.scancode-type.hint")
            onRender: (field) ->
                disableEnableScancodeType(field)
            options: ->
                options = []
                # Barcodes available https://github.com/lindell/JsBarcode/wiki#barcodes
                for option in [ez5.Scancode.DEFAULT_BARCODE_TYPE, "CODE39", "ITF14", "MSI", "pharmacode", "codabar", "EAN13", "UPC", "EAN8", "EAN5", "EAN2"]
                    options.push(value: option)
                return options
        ,
            type: CUI.Input
            name: "code_prefix"
            form:
                label: $$("scancode.custom.splitter.options.code_prefix.label")
                hint: $$("scancode.custom.splitter.options.code_prefix.hint")
        ,
            fieldSelector
        ,
            type: CUI.Input
            name: "code_suffix"
            form:
                label: $$("scancode.custom.splitter.options.code_suffix.label")
                hint: $$("scancode.custom.splitter.options.code_suffix.hint")           
        ]
        downloadField = 
            type: CUI.Checkbox
            name: "allow_download"
            form:
                label: $$("scancode.custom.splitter.options.download.label")
                hint: $$("scancode.custom.splitter.options.download.hint")
        if showDownloadOptions
            fields.push downloadField

        return fields

    renderField: (opts) ->
        fieldName = @getDataOptions().field_name
        if not fieldName # Not configured.
            return

        if fieldName in ['_uuid', '_system_object_id', '_global_object_id']
            _data = opts.top_level_data
            data = _data[fieldName]
        else
            _data = opts.data
            data = _data[fieldName]

        # add prefix and suffix if given
        if @.opts?.options?.code_prefix
            data = @.opts.options.code_prefix + data
        if @.opts?.options?.code_suffix
            data = data + @.opts.options.code_suffix

        localizedDisplayName = _data["#{fieldName}:rendered"]?.getField().fullNameLocalized();

        scancode = new ez5.Scancode
            type: @getDataOptions().code_type
            scancode_type: @getDataOptions().scancode_type
            mode: opts.mode
            download: @getDataOptions().allow_download
        scancode.render(data, {
            displayName: localizedDisplayName,
            fieldName: fieldName,
            objectType: opts.top_level_data._objecttype,
        })

    hasContent: (opts) ->
        fieldName = @getDataOptions().field_name
        if not fieldName # Not configured.
            return false
        data = opts.data[fieldName]
        return !!data

    isEnabledForNested: ->
        return true

MaskSplitter.plugins.registerPlugin(ez5.ScancodeMaskSplitter)
