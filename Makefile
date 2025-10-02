ZIP_NAME ?= "ScancodeDisplay.zip"
PLUGIN_NAME = easydb-barcode-display

COFFEE_FILES = \
	Scancode.coffee \
	ScancodeEditorPlugin.coffee \
	ScancodeMaskSplitter.coffee \
	ScancodeSearchExpertPlugin.coffee \
	ScancodeNode.coffee

JS_FILES = \
	JsBarcode.all.min.js \
	qrcode.min.js

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: build zip ## build and zip

build: clean buildinfojson ## build plugin
	mkdir -p build
	mkdir -p build/$(PLUGIN_NAME)/webfrontend
	mkdir -p build/$(PLUGIN_NAME)/l10n
	mkdir -p src/tmp

	cp src/webfrontend/*.coffee src/tmp
	cd src/tmp && coffee -b --compile ${COFFEE_FILES}

	cat src/thirdparty/jsbarcode/JsBarcode.all.min.js src/thirdparty/qrcode/qrcode.min.js src/tmp/*.js > build/$(PLUGIN_NAME)/webfrontend/scancode-display.js

	rm -rf src/tmp

	cp l10n/scancodeDisplay.csv build/$(PLUGIN_NAME)/l10n/scancode-display.csv
	cp src/webfrontend/css/scancodeDisplay.css build/$(PLUGIN_NAME)/webfrontend/scancode-display.css
	cp manifest.master.yml build/$(PLUGIN_NAME)/manifest.yml

clean: ## clean
	rm -rf build

zip: build ## zip file
	cd build && zip ${ZIP_NAME} -r $(PLUGIN_NAME)/

buildinfojson:
	repo=`git remote get-url origin | sed -e 's/\.git$$//' -e 's#.*[/\\]##'` ;\
	rev=`git show --no-patch --format=%H` ;\
	lastchanged=`git show --no-patch --format=%ad --date=format:%Y-%m-%dT%T%z` ;\
	builddate=`date +"%Y-%m-%dT%T%z"` ;\
	echo '{' > build-info.json ;\
	echo '  "repository": "'$$repo'",' >> build-info.json ;\
	echo '  "rev": "'$$rev'",' >> build-info.json ;\
	echo '  "lastchanged": "'$$lastchanged'",' >> build-info.json ;\
	echo '  "builddate": "'$$builddate'"' >> build-info.json ;\
	echo '}' >> build-info.json
