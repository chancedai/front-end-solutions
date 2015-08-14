(function() {
	var doc = document,
		btn = (function() {
			var body = doc.body,
				firstChild = body.firstChild,
				btn = doc.createElement('a');
			btn.className = 'side-btns-top-btn';
			btn.href = 'javascript:;';
			btn.title = '返回顶部';
			btn.innerHTML = '返回顶部';
			firstChild ? firstChild.parentNode.insertBefore(btn, firstChild) : body.appendChild(btn);
			return btn;
		})(),
		addEvent = function(o, s, fn) {
			if (o.attachEvent) {
				o.attachEvent('on' + s, fn);
			} else {
				o.addEventListener(s, fn, false);
			}
			return o;
		}, toggle = function() {
			var top = doc.documentElement.scrollTop || doc.body.scrollTop,
				visible = (top > 0 ? 'visible' : 'hidden');
			btn.style.visibility = visible;
		}, toTop = function() {
			doc.documentElement.scrollTop = 0;
			doc.body.scrollTop = 0;
		};
	addEvent(window, 'scroll', toggle);
	addEvent(btn, 'click', toTop);
})();