console.log('b.js loaded');
var domReady = (function() {
	var doc = document;
	var fns = [],
		inited = 0,
		isReady = 0;
	var checkReady = function() {
		if (doc.readyState === 'complete') {
			return 1;
		}
		return isReady;
	};

	var onReady = function(type) {
		if (isReady) {
			return;
		}
		isReady = 1;

		if (fns) {
			while (fns.length) {
				fns.shift()();
			}
		}
		fns = null;
	};
	var bindReady = function() {
		if (inited) {
			return;
		}
		inited = 1;

		//开始初始化domReady函数，判定页面的加载情况
		if (doc.readyState === 'complete') {
			onReady();
		} else if (doc.addEventListener) {
			doc.addEventListener('DOMContentLoaded', function() {
				doc.removeEventListener('DOMContentLoaded', arguments.callee, false);
				onReady();
			}, false);
			//不加这个有时chrome firefox不起作用
			window.addEventListener('load', function() {
				window.removeEventListener('load', arguments.callee, false);
				onReady();
			}, false);
		} else {
			doc.attachEvent('onreadystatechange', function() {
				if (doc.readyState == 'complete') {
					doc.detachEvent('onreadystatechange', arguments.callee);
					onReady();
				}
			});
			(function() {
				if (isReady) {
					return;
				}
				var node = new Image();
				try {
					node.doScroll();
					node = null; //防止IE内存泄漏
				} catch (e) {
					setTimeout(arguments.callee, 64);
					return;
				}
				onReady();
			})();
		}
	};
	return function(fn) {
		bindReady();
		if (!checkReady()) {
			fns.push(fn);
			return;
		}
		//onReady();
		fn.call();
	};
})();
domReady(function(){
	console.log('b.js domready');
});