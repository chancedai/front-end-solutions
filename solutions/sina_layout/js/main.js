(function(exports,undefined){
	var getNodes = function(wrap,attr) {
        attr = attr||'node-type';
        wrap = $('#' + wrap);
        var nodes = $("[" + attr + "]", wrap);
        var nodesObj = {};
        nodesObj.wrap = wrap;
        nodes.each(function(i) {
            var item = $(this);
            nodesObj[item.attr(attr)] = item;
        });
        return nodesObj;
    };
    var addCSS = function(url) {
        var link = document.createElement('link');
        link.type = 'text/css';
        link.rel = 'stylesheet';
        link.href = url;
        document.getElementsByTagName('head')[0].appendChild(link);
        return link;
    };
    var addJS = function(url,cb){
    	var js = $.getScript(url, function(){
    		if(typeof cb === 'function'){
    			cb();
    		}
    	});
    	return js;
    };
    var Layout = {
    	getNodes:getNodes,
    	addCSS:addCSS,
    	addJS:addJS
    };
	exports.LAYOUT = Layout;
})(window);