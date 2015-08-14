#target Photoshop
var getSize = function() {
	var activeLayer = null;
	try{
		activeLayer = app.activeDocument.activeLayer;
	}catch(e){

	}
	if (activeLayer) {
		return {
			width: activeLayer.bounds[2].as('px') - activeLayer.bounds[0].as('px'),
			height: activeLayer.bounds[3].as('px') - activeLayer.bounds[1].as('px')
		};
	} else {
		return {
			width:0,
			height:0
		};
	}

};
var size = getSize();
var dlg = new Window('dialog', 'Select Type');
dlg.st = dlg.add('statictext', undefined, '', {
	multiline: true
});
dlg.st.text = 'Width:' + size.width + '\rHeight:' + size.height;
dlg.center();
dlg.show();