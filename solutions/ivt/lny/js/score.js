;(function(){
    	var NODEATTR = 'node-type';
    	var getNodes = function(wrap) {
    	    var attr = NODEATTR||'node-type';
    	    var wrap = $(wrap);
    	    var nodes = $("[" + attr + "]", wrap);
    	    var nodesObj = {};
    	    nodesObj.wrap = wrap;
    	    nodes.each(function(i) {
    	        var item = $(this);
    	        nodesObj[item.attr(attr)] = item;
    	    });
    	    return nodesObj;
    	};
    	var setHeight = function(){
    		if(!display){
    			return;
    		}
    		dom.layer.css({
    			height:dom.listWrap.height()
    		});
    	};
    	var show = function(){
    		dom.layer.show();
    		display = true;
    		setHeight();
    	};
    	var hide = function(){
    		dom.layer.hide();
    		display = false;
    	};
    	var display = false;
    	var dom = getNodes('#js_page_score');
    	// 打开收起
    	dom.wrap.on('click','['+NODEATTR+'=trigger]',function(e){
    		if(display){
    			hide();
    		}else{
    			show();
    		}
    	});
    	dom.wrap.on('click','['+NODEATTR+'=close]',function(e){
			hide();
    	});
    	$(window).on('resize',setHeight);
    })();