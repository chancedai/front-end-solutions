/**
 * modalEffects.js v1.0.0
 * http://www.codrops.com
 *
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2013, Codrops
 * http://www.codrops.com
 */
var ModalEffects = (function() {
	var byClz = (function() {
	    var by;
	    var doc = document;
	    if ('function' === typeof doc.getElementsByClassName) {
	        by = function(clz, wrap) {
	            if (wrap) {
	                return wrap.getElementsByClassName(clz);
	            } else {
	                return doc.getElementsByClassName(clz);
	            }
	        };
	    } else {
	        by = function(clz, wrap) {
	            for (var i = -1, results = [], finder = new RegExp('(?:^|\\s)' + clz + '(?:\\s|$)'), a = wrap && wrap.getElementsByTagName && wrap.getElementsByTagName('*') || doc.all || doc.getElementsByTagName('*'), l = a.length; ++i < l; finder.test(a[i].className) && results.push(a[i]));
	            a = null;
	            return results;
	        };
	    }
	    return by;
	})();
	var addEvent = function(el, type, fn, useCapture) {
		if (typeof useCapture == 'undefined') {
			useCapture = false;
		}
		if (el.addEventListener) {
			el.addEventListener(type, fn, useCapture);
			return true;
		} else if (el.attachEvent) {
			var r = el.attachEvent('on' + type, fn);
			return true;
		} else {
			el['on' + type] = fn;
		}
	};
	var removeEvent = function (el, type,fn) {
		if (el.addEventListener) {
			el.removeEventListener(type, fn, false);
		}
		else if (el.attachEvent) {
			el.detachEvent('on' + type, fn);
		}
		fn[type] = null;
	};
	var stopPropagation = function(e) {
		if (e && e.stopPropagation) {
			e.stopPropagation();
		} else {
			window.event.cancelBubble = true;
		}
		return false;
	};

	function init() {

		var overlay = byClz( 'md-overlay' )[0];
		var triggers = byClz('md-trigger');
		for (var i = 0, len = triggers.length; i < len; i++) {
			(function(i){
				var el = triggers[i];
				var modal = document.getElementById(el.getAttribute( 'data-modal' ) ),
					close = byClz('md-close', modal)[0];

				function removeModal( hasPerspective ) {
					classie.remove( modal, 'md-show' );

					if( hasPerspective ) {
						classie.remove( document.documentElement, 'md-perspective' );
					}
				}

				function removeModalHandler() {
					removeModal( classie.has( el, 'md-setperspective' ) );
				}
				addEvent(el, 'click', function( ev ) {
					classie.add( modal, 'md-show' );
					removeEvent(overlay,'click',removeModalHandler);
					addEvent(overlay, 'click', removeModalHandler);

					if( classie.has( el, 'md-setperspective' ) ) {
						setTimeout( function() {
							classie.add( document.documentElement, 'md-perspective' );
						}, 25 );
					}
				});
				addEvent(close, 'click',  function( ev ) {
					ev = ev||window.event;
					stopPropagation(ev);
					removeModalHandler();
				})
			})(i);

		}


	}

	init();

})();