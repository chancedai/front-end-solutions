
(function(){
	// http://....getOptionsBySelfUrl.js#a=1&b=2&c=3
	var getScriptOptions = function() {
		var parseOptions = function(src, decode) {
			var options = {};
			if (src = /\?(.*)|#(.*)/.exec(src))
				for (var src = src[0].slice(1).replace("+", " "), params = src.split(/[&;]/g), i = 0, len = params.length; i < len; i++) {
					var paramsArr = params[i].split("="),
						key = decodeURIComponent(paramsArr[0]),
						val = decode ? paramsArr[1] : null;
					if (!decode) {
						try {
							val = decodeURIComponent(paramsArr[1])
						} catch (e) {}
					}
					options[key] = val;
				}
			return options;
		};
		var src = '';
		for (var jss = document.getElementsByTagName('script'), i = 0, len = jss.length; i < len; i++) {
			var cSrc = jss[i].src;
			if(cSrc && cSrc.search('getOptionsBySelfUrl') >= 0){
				src = cSrc;
			}
		}
		return parseOptions(src);
	};
	var jss = getScriptOptions();
	console.log(jss);
})();