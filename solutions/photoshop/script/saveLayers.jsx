
#target photoshop
// Makes Photoshop the active application
app.bringToFront();
var isPsd = function() {
    if (!documents.length){
        return false
    }
    var doc = app.activeDocument;
    var ext = decodeURI(doc.name).replace(/^.*\./,'');
    return ext.toLowerCase() == 'psd'
};
var addDropdownlist = function(win){
    return win.add('dropdownlist', undefined, '');
};
var addDropdownItem = function(list,label){
    list.add ('item', label);
};
var saveImg = function(saveFile,type,quality){
    function savePNG8() {
        var exportOptionsSaveForWeb = new ExportOptionsSaveForWeb();
        exportOptionsSaveForWeb.format = SaveDocumentType.PNG
        exportOptionsSaveForWeb.dither = Dither.NONE;
        activeDocument.exportDocument( saveFile, ExportType.SAVEFORWEB, exportOptionsSaveForWeb );
    }
    function savePNG24() {
        var pngSaveOptions = new PNGSaveOptions();
        activeDocument.saveAs(saveFile, pngSaveOptions, true, Extension.LOWERCASE);
    }
    function saveJPEG() {
        var jpegSaveOptions = new JPEGSaveOptions();
        jpegSaveOptions.quality = parseInt(quality,10);
        activeDocument.saveAs(saveFile, jpegSaveOptions, true, Extension.LOWERCASE);
    }
    type = type.toLowerCase();
    switch (type) {
        case 'png':
            if(quality==='8'){
                savePNG8();
            }else{
                savePNG24();
            }
            break;
        default:
            saveJPEG(quality);
    }
};
var alertDialog = function() {
    // build dialogue
    var dlg = new Window ('dialog', 'Select Type');
    dlg.saver = addDropdownlist(dlg);
    dlg.quality = addDropdownlist(dlg);
    dlg.pngtype = addDropdownlist(dlg);

    // file type
    var saveOpt = ['PNG','JPG'];
    for (var i = 0, len = saveOpt.length; i < len; i++) {
        addDropdownItem(dlg.saver,'Save as '+saveOpt[i]);
    }
    // trigger function
    dlg.saver.onChange = function() {
        prefs.fileType = saveOpt[parseInt(this.selection)];
        // decide whether to show JPG or PNG options
        if(prefs.fileType==saveOpt[1]){
            dlg.quality.show();
            dlg.pngtype.hide();
        } else {
            dlg.quality.hide();
            dlg.pngtype.show();
        }
    };

    // jpg quality
    var qualityOpt = [];
    for(var i=12; i>=1; i--) {
        qualityOpt.push(i);
        addDropdownItem(dlg.quality,''+i);
    };

    // png type
    var pngtypeOpt = [8,24];
    for (var i = 0, len = pngtypeOpt.length; i < len; i++) {
        addDropdownItem(dlg.pngtype,''+pngtypeOpt[i]);
    }
    // trigger functions
    dlg.quality.onChange = function() {
        prefs.fileQuality = qualityOpt[12-parseInt(this.selection)];
    };
    dlg.pngtype.onChange = function() {
       prefs.fileQuality = pngtypeOpt[parseInt(this.selection)];
    };

    // remainder of UI
    dlg.btnRun = dlg.add("button", undefined, 'Continue' );
    dlg.btnRun.onClick = function() {
        this.parent.close(0);
    };

    dlg.orientation = 'column';

    dlg.saver.selection = dlg.saver.items[0] ;
    dlg.quality.selection = dlg.quality.items[0] ;
    dlg.center();
    dlg.show();
};
var prefs;
function main() {
    // two quick checks
	if(!isPsd()) {
        alert("Document must be saved and be a layered PSD.");
        return;
    }
    var len = activeDocument.layers.length;
    var ok = confirm("Note: All layers will be saved in same directory as your PSD.\nThis document contains " + len + " top level layers.\nBe aware that large numbers of layers may take some time!\nContinue?");
    if(!ok){
        return;
    }

    // user preferences
    prefs = new Object();
    prefs.fileType = "";
    prefs.fileQuality = 12;
    prefs.filePath = app.activeDocument.path;
    prefs.count = 0;

    //instantiate dialogue
    alertDialog();
    hideLayers(activeDocument);
    saveLayers(activeDocument);
    toggleVisibility(activeDocument);
    alert("Saved " + prefs.count + " files.");
}

function hideLayers(doc) {
    var layers = doc.layers;
    for (var i = 0, len = layers.length; i < len; i++) {
        var layer = layers[i];
        if (layer.typename == 'LayerSet'){
            hideLayers(layer);
        }else{
            layer.visible = false;
        }
    };
}

function toggleVisibility(doc) {
    var layers = doc.layers;
    for (var i = 0, len = layers.length; i < len; i++) {
        var layer = layers[i];
        layer.visible = !layer.visible;
    };
}

function saveLayers(doc) {
    var layers = doc.layers;
    for (var i = 0, len = layers.length; i < len; i++) {
        var layer = layers[i];
        if (layer.typename == 'LayerSet') {
            // recurse if current layer is a group
            hideLayers(layer);
            saveLayers(layer);
        } else {
            // otherwise make sure the layer is visible and save it
            layer.visible = true;
            saveLayerToImg(layer.name);
            layer.visible = false;
        }
    };
}

function saveLayerToImg(layerName) {
    var fileName = layerName.replace(/[\\\*\/\?:"\|<> ]/g,'')||'anonymous';
    var getFiles = function(){
        return getUniqueName(prefs.filePath + "/" + fileName);
    };
    prefs.count++;
    saveImg(getFiles(), prefs.fileType, prefs.fileQuality);
}

function getUniqueName(fileroot) {
    // form a full file name
    // if the file name exists, a numeric suffix will be added to disambiguate
    var filename = fileroot;
    var handle = File(filename + "." + prefs.fileType);
    if(handle.exists) {
        filename = fileroot + "-" + (Math.abs((new Date()).getTime()) + '_' + Math.round(Math.random() * 1e8));
        handle = File(filename + "." + prefs.fileType);
    }
    return handle;
}

function wrapper() {
    try {
        // suspend history for CS3 or higher
        if (parseInt(version, 10) >= 10) {
            activeDocument.suspendHistory('Save Layers', 'main()');
        } else {
            main();
        }
    } catch(e) {
        // report errors unless the user cancelled
        if (e.number != 8007){
            alert(e + ': on line ' + e.line, 'Script Error', true);
        };
    }
}

wrapper();
