;
(function() {
	var NODEATTR = 'node-type';
	var getNodes = function(wrap) {
		var attr = NODEATTR || 'node-type';
		var wrap = $('#' + wrap);
		var nodes = $("[" + attr + "]", wrap);
		var nodesObj = {};
		nodesObj.wrap = wrap;
		nodes.each(function(i) {
			var item = $(this);
			nodesObj[item.attr(attr)] = item;
		});
		return nodesObj;
	};
	var show = function() {
		dom.layer.show();
		display = true;
	};
	var hide = function() {
		dom.layer.hide();
		display = false;
	};
	var display = false;
	var dom = getNodes('j_post_info');
	// 打开收起
	dom.wrap.on('click', '[' + NODEATTR + '=trigger]', function(e) {
		if (display) {
			hide();
		} else {
			show();
		}
		e.stopPropagation();
	});
	// 全局关闭
	$('body').on('click', function(e) {
		var el = $(this);
		if (!display) {
			return;
		}
		// if($.contains(dom.layer,el)){
		// 	return;
		// }
		hide();
	});
	dom.layer.on('click', function(e) {
		e.stopPropagation();
	});
})();