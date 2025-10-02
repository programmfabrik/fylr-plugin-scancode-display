# easydb-barcode-display

Custom Mask Splitter for **fylr** to output scancodes based on data of another field in the record. Various barcode formats and QR codes are available. This plugin can be used in datamodel-masks and also in the pdfcreator.

## installation
The latest version of this plugin can be found [here](https://github.com/programmfabrik/fylr-plugin-scancode-display/releases/latest/download/ScancodeDisplay.zip).

The ZIP can be downloaded and installed using the plugin manager, or used directly (recommended).

Github has an overview page to get a list of [all releases](https://github.com/programmfabrik/fylr-plugin-scancode-display/releases/).

## requirements
This plugin requires https://github.com/programmfabrik/fylr-plugin-pdf-creator. In order to use this plugin, you need to add the [pdf-creator](https://github.com/programmfabrik/fylr-plugin-pdf-creator) to your pluginmanager.

## configuration

Available Options in the maskconfiguration and the pdfcreator are:

* type (barcode or qrcode)
* type of (which type of barcode exactly)
* prefix
* suffix
* field whose data is used
* show downloadbutton (only for mask, not for pdf)

## sources

The source code of this plugin is managed in a git repository at <https://github.com/programmfabrik/fylr-plugin-scancode-display>.