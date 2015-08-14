console.log('a.js loaded');
;(function(win, doc, js) {
	var js = doc.createElement('script')
	js.src = 'b.js';
	js.async = 'false';
	var head = doc.getElementsByTagName('head')[0];
	head.appendChild(js);
	console.log('加载b.js');
})(window, document);