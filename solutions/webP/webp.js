(function(window,undefined){
	function noop(){};
	// 是否支持webP
	var _isSupport = false;
	// 本地存储
	var LStorage = (function() {
	  var key = 'support_webp_'
	  var localStorageName = 'localStorage';
	  var isLocalStorageSupport = ((localStorageName in window) && window[localStorageName]);
	  if (isLocalStorageSupport) {
	    return {
	      set: function(val) {
	        try {
	          localStorage.setItem(key, val);
	        } catch (e) {}
	      },
	      get: function() {
	        return localStorage.getItem(key);
	      }
	    };
	  } else {
	    return {
	      set: function() {},
	      get: function() {
	        return '';
	      }
	    };
	  }
	})();

	var isSupport = (function(){
		function isSupportLint(fn){
			fn = fn|| noop;
			fn(_isSupport);
			// console.log('默认使用这个，最快！！！');
		};
		// 是否存在本地存储的判断结果
		var localResult = LStorage.get(_isSupport);
		if (localResult) {
		  // console.log('使用本地判断，每次刷新只出现一次');
		  _isSupport = localResult === 'true' ? true : false;
		  return isSupportLint;
		} else {
		  // 无结果
		  return function(fn) {
		  	fn = fn|| noop;
		    var img = new Image();
		    img.onload = img.onerror = function() {
		      _isSupport = img.height === 2;
		      // 支持情况保存在本地
		      LStorage.set(_isSupport);
		      // 不再使用图片加载来判断
		      isSupport = isSupportLint;
		      fn(_isSupport);
		      // console.log('使用图片加载判断，不管如何刷新只出现一次');
		    };
		    img.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
		  };
		}
	})();
	function get(src){
		if(_isSupport){
			var hasWebP = false;
			if(!/_\.webp$/i.test(src)){
				var reg = /^http:\/\/(\w{1})(\d{1})\.sinaimg\.cn/i;
				src = src.replace(reg, function(m, p1, p2) {
					hasWebP = true;
				  	return 'http://k'+ p2 +'.sinaimg.cn/'+p1+p2;
				});
				if(hasWebP){
					src += '_.webp';
				}
			}
		}
		return src;
	};
	// 提前判断
	isSupport();
	window.WebP = {
		isSupport:isSupport,
		get:get
	};
})(window);


