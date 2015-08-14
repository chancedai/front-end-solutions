var Util = {
	ua: (function() {
		var ua = navigator.userAgent.toLowerCase();
		var test = function(re) {
			return re.test(ua);
		};
		var IS = 'is';
		return {
			'isIE': test(/msie/),
			'isOPERA': test(/opera/),
			'isMOZ': test(/gecko/),
			'isIE6': test(/msie 6/),
			'isIE7': test(/msie 7/),
			'isSAFARI': test(/safari/),
			'iswinXP': test(/windows nt 5.1/),
			'iswinVista': test(/windows nt 6.0/),
			'isFF': test(/firefox/),
			'isIOS': test(/\((iPhone|iPad|iPod)/i),
			'isMOBILE': test(/mobile/i)
		};
	})(),
	parseParam: function(oSource, oParams) {
		var key;
		try {
			if (typeof oParams != 'undefined') {
				for (key in oSource) {
					if (oParams[key] != null) {
						oSource[key] = oParams[key];
					}
				}
			}
		} finally {
			key = null;
			return oSource;
		}
	},
	fixEvent: function(e) {
		e = window.event || e;
		if (!e.target) {
			e.target = e.srcElement;
			e.pageX = e.x;
			e.pageY = e.y;
		}
		e.layerX = e.layerX || e.offsetX;
		e.layerY = e.layerY || e.offsetY;
		return e;
	},
	addEvent: function(elm, evType, func, useCapture) {
		var _el = elm;
		if (_el == null) {
			throw new Error('addEvent 找不到对象：' + elm);
			return;
		}
		if (typeof useCapture == 'undefined') {
			useCapture = false;
		}
		if (typeof evType == 'undefined') {
			evType = 'click';
		}
		if (_el.addEventListener) {
			_el.addEventListener(evType, func, useCapture);
			return true;
		} else if (_el.attachEvent) {
			var r = _el.attachEvent('on' + evType, func);
			return true;
		} else {
			_el['on' + evType] = func;
		}
	},
	removeEvent: function(oElement, sName, fHandler) {
		var _el = oElement;
		if (_el == null) {
			throw ('removeEvent 找不到对象：' + oElement);
			return;
		}
		if (typeof fHandler != 'function') {
			return;
		}
		if (typeof sName == 'undefined') {
			sName = 'click';
		}
		if (_el.addEventListener) {
			_el.removeEventListener(sName, fHandler, false);
		} else if (_el.attachEvent) {
			_el.detachEvent('on' + sName, fHandler);
		}
		fHandler[sName] = null;
	},
	stopEvent: function(e) {
		e = this.fixEvent(e);
		if (Util.ua.isIE) {
			e.cancelBubble = true;
			e.returnValue = false
		} else {
			e.preventDefault();
			e.stopPropagation();
		}
		return false
	},
	isArray: function(o) {
		return Object.prototype.toString.call(o) === '[object Array]';
	},
	scrollPos: function(doc) {
		doc = doc || document;
		var dd = doc.documentElement;
		var db = doc.body;
		var getMax = function(a, b) {
			return Math.max(a, b);
		};
		return {
			top: getMax(dd.scrollTop, db.scrollTop),
			left: getMax(dd.scrollLeft, db.scrollLeft),
			width: getMax(dd.scrollWidth, db.scrollWidth),
			height: getMax(dd.scrollHeight, db.scrollHeight)
		};
	},
	position: (function() {
		var getPos = function(ele) {
			var clientRect, scrollInfo, docBody, docEle, clientTop, clientLeft;
			clientRect = ele.getBoundingClientRect();
			scrollInfo = Util.scrollPos();
			docBody = ele.ownerDocument.body;
			docEle = ele.ownerDocument.documentElement;
			clientTop = docEle.clientTop || docBody.clientTop || 0;
			clientLeft = docEle.clientLeft || docBody.clientLeft || 0;
			return {
				l: parseInt(clientRect.left + scrollInfo.left - clientLeft, 10) || 0,
				t: parseInt(clientRect.top + scrollInfo.top - clientTop, 10) || 0
			}
		};
		var getOffset = function(ele, wrap) {
			var offset;
			offset = [ele.offsetLeft, ele.offsetTop];
			parent = ele.offsetParent;
			if (parent !== ele && parent !== wrap) {
				while (parent) {
					offset[0] += parent.offsetLeft;
					offset[1] += parent.offsetTop;
					parent = parent.offsetParent
				}
			}
			if (Util.ua.isOPERA != -1 || (Util.ua.isSAFARI != -1 && ele.style.position == 'absolute')) {
				offset[0] -= document.body.offsetLeft;
				offset[1] -= document.body.offsetTop
			}
			if (ele.parentNode) {
				parent = ele.parentNode
			} else {
				parent = null
			}
			while (parent && !/^body|html$/i.test(parent.tagName) && parent !== wrap) {
				if (parent.style.display.search(/^inline|table-row.*$/i)) {
					offset[0] -= parent.scrollLeft;
					offset[1] -= parent.scrollTop
				}
				parent = parent.parentNode
			}
			return {
				l: parseInt(offset[0], 10),
				t: parseInt(offset[1], 10)
			}
		};
		return function(ele, d) {
			if (ele == document.body || ele.parentNode == null || ele.style.display == 'none') {
				return false
			}
			var param = Util.parseParam({
				parent: null
			}, d);
			if (ele.getBoundingClientRect) {
				if (param.parent) {
					var pos = getPos(ele);
					var parPos = getPos(param.parent);
					return {
						l: pos.l - parPos.l,
						t: pos.t - parPos.t
					}
				} else {
					return getPos(ele);
				}
			} else {
				return getOffset(ele, param.parent || document.body)
			}
		}
	})()
};
Util.custEvent = (function() {
	var _custAttr = '__custEventKey__',
		_custKey = 1,
		_custCache = {},
		/**
		 * 从缓存中查找相关对象
		 * 当已经定义时
		 * 	有type时返回缓存中的列表 没有时返回缓存中的对象
		 * 没有定义时返回false
		 * @param {Object|number} obj 对象引用或获取的key
		 * @param {String} type 自定义事件名称
		 */
		_findObj = function(obj, type) {
			var _key = (typeof obj == 'number') ? obj : obj[_custAttr];
			return (_key && _custCache[_key]) && {
				obj: (typeof type == 'string' ? _custCache[_key][type] : _custCache[_key]),
				key: _key
			};
		};

	return {
		/**
		 * 对象自定义事件的定义 未定义的事件不得绑定
		 * @method define
		 * @static
		 * @param {Object|number} obj 对象引用或获取的下标(key); 必选
		 * @param {String|Array} type 自定义事件名称; 必选
		 * @return {number} key 下标
		 */
		define: function(obj, type) {
			if (obj && type) {
				var _key = (typeof obj == 'number') ? obj : obj[_custAttr] || (obj[_custAttr] = _custKey++),
					_cache = _custCache[_key] || (_custCache[_key] = {});
				type = [].concat(type);
				for (var i = 0; i < type.length; i++) {
					_cache[type[i]] || (_cache[type[i]] = []);
				}
				return _key;
			}
		},

		/**
		 * 对象自定义事件的取消定义
		 * 当对象的所有事件定义都被取消时 删除对对象的引用
		 * @method define
		 * @static
		 * @param {Object|number} obj 对象引用或获取的(key); 必选
		 * @param {String} type 自定义事件名称; 可选 不填可取消所有事件的定义
		 */
		undefine: function(obj, type) {
			if (obj) {
				var _key = (typeof obj == 'number') ? obj : obj[_custAttr];
				if (_key && _custCache[_key]) {
					if (typeof type == 'string') {
						if (type in _custCache[_key]) delete _custCache[_key][type];
					} else {
						delete _custCache[_key];
					}
				}
			}
		},

		/**
		 * 事件添加或绑定
		 * @method add
		 * @static
		 * @param {Object|number} obj 对象引用或获取的(key); 必选
		 * @param {String} type 自定义事件名称; 必选
		 * @param {Function} fn 事件处理方法; 必选
		 * @param {Any} data 扩展数据任意类型; 可选
		 * @return {number} key 下标
		 */
		add: function(obj, type, fn, data) {
			if (obj && typeof type == 'string' && fn) {
				var _cache = _findObj(obj, type);
				if (!_cache || !_cache.obj) {
					throw 'custEvent (' + type + ') is undefined !';
				}
				_cache.obj.push({
					fn: fn,
					data: data
				});
				return _cache.key;
			}
		},

		/**
		 * 事件删除或解绑
		 * @method remove
		 * @static
		 * @param {Object|number} obj 对象引用或获取的(key); 必选
		 * @param {String} type 自定义事件名称; 可选; 为空时删除对象下的所有事件绑定
		 * @param {Function} fn 事件处理方法; 可选; 为空且type不为空时 删除对象下type事件相关的所有处理方法
		 * @return {number} key 下标
		 */
		remove: function(obj, type, fn) {
			if (obj) {
				var _cache = _findObj(obj, type),
					_obj;
				if (_cache && (_obj = _cache.obj)) {
					if (Util.isArray(_obj)) {
						if (fn) {
							for (var i = 0; i < _obj.length && _obj[i].fn !== fn; i++);
							_obj.splice(i, 1);
						} else {
							_obj.splice(0);
						}
					} else {
						for (var i in _obj) {
							_obj[i] = [];
						}
					}
					return _cache.key;
				}
			}
		},

		/**
		 * 事件触发
		 * @method fire
		 * @static
		 * @param {Object|number} obj 对象引用或获取的(key); 必选
		 * @param {String} type 自定义事件名称; 必选
		 * @param {Any|Array} args 参数数组或单个的其他数据; 可选
		 * @return {number} key 下标
		 */
		fire: function(obj, type, args) {
			if (obj && typeof type == 'string') {
				var _cache = _findObj(obj, type),
					_obj;
				if (_cache && (_obj = _cache.obj)) {
					if (!Util.isArray(args)) {
						args = args != undefined ? [args] : [];
					}
					for (var i = 0; i < _obj.length; i++) {
						var fn = _obj[i].fn;
						if (fn && fn.apply) {
							// TODO 修正$
							// fn.apply($, [{type: type, data: _obj[i].data}].concat(args));
							fn.apply(this, [{
									type: type,
									data: _obj[i].data
								}
							].concat(args));
						}
					}
					return _cache.key;
				}
			}
		},
		/**
		 * 销毁
		 * @method destroy
		 * @static
		 */
		destroy: function() {
			_custCache = {};
			_custKey = 1;
		}
	};
})();
Util.drag = (function(self) {
	var doc = document;
	var _custEvent = self.custEvent;
	var _addEvent = self.addEvent;
	var _click = function(evt) {
		evt.cancelBubble = true;
		return false
	}, objClone = function(nObj, oObj) {
			nObj.clientX = oObj.clientX;
			nObj.clientY = oObj.clientY;
			nObj.pageX = oObj.clientX + Util.scrollPos().left;
			nObj.pageY = oObj.clientY + Util.scrollPos().top;
			nObj.offsetX = oObj.offsetX || oObj.layerX;
			nObj.offsetY = oObj.offsetY || oObj.layerY;
			nObj.target = oObj.target || oObj.srcElement;
			return nObj;
		};
	return function(ele, config) {
		var param = Util.parseParam({
			actRect: [],
			actObj: {}
		}, config),
			Drag = {}, custEventObj = _custEvent.define(param.actObj, 'dragStart'),
			custEventObjEnd = _custEvent.define(param.actObj, 'dragEnd'),
			custEventObjDraging = _custEvent.define(param.actObj, 'draging'),
			_mouseDown = function(evt) {
				var oEvt = objClone({}, evt);
				doc.body.onselectstart = function() {
					return false;
				};
				_addEvent(doc, 'mousemove', _mouseMove);
				_addEvent(doc, 'mouseup', _mouseUp);
				// TODO 会阻止其它绑定在doc上面的事件
				// _addEvent(doc, 'click', _click, true);
				if (!Util.ua.isIE) {
					evt.preventDefault();
					evt.stopPropagation();
				}
				_custEvent.fire(custEventObj, 'dragStart', oEvt);
				return false;
			}, _mouseMove = function(evt) {
				var oEvt = objClone({}, evt);
				evt.cancelBubble = true;
				_custEvent.fire(custEventObj, 'draging', oEvt)
			}, _mouseUp = function(evt) {
				var oEvt = objClone({}, evt);
				doc.body.onselectstart = function() {
					return true;
				};
				Util.removeEvent(doc, 'mousemove', _mouseMove);
				Util.removeEvent(doc, 'mouseup', _mouseUp);
				Util.removeEvent(doc, 'click', _click, true);
				_custEvent.fire(custEventObj, 'dragEnd', oEvt)
			};
		_addEvent(ele, 'mousedown', _mouseDown);
		Drag.destroy = function() {
			Util.removeEvent(ele, 'mousedown', _mouseDown);
			param = null
		};
		Drag.getActObj = function() {
			return param.actObj;
		};
		return Drag;
	}
})(Util);
var ScrollBar = (function(a) {
	var ScrollBar = {}, _addEvent = Util.addEvent,
		_custEvent = Util.custEvent;
	var setStyle = function(ele, pro, val) {
		if (ele) {
			ele.style[pro] = val;
		}
		return ele;
	};
	return function(e) {
		var d,contentOuter, contentInner, dragOuter, dragInner, contentOuterPos, dragInnerPos, dragStartOffsetY, dragInnerHeight, dragInnerTop, isMOBILE = false,
			dragOuterClick = function(evt) {
				var evt = Util.fixEvent(evt),
					target = evt.target;
				dragOuterPos = Util.position(dragOuter);
				var dragInnerPosTop = evt.clientY - dragOuterPos.t,
					contentInnerMarginTop;
				if (target != dragInner) {
					contentInnerMarginTop = parseInt(dragInnerPosTop * contentInner.offsetHeight / dragOuter.offsetHeight, 10);
					contentInnerMarginTop >= Math.abs(contentOuter.offsetHeight - contentInner.offsetHeight) && (contentInnerMarginTop = contentInner.offsetHeight - contentOuter.offsetHeight);
					if (dragInnerPosTop < 0){
						return;
					}
					dragInnerPosTop + dragInner.offsetHeight > dragOuter.offsetHeight && (dragInnerPosTop = dragOuter.offsetHeight - dragInner.offsetHeight);
					contentInnerMarginTop >= Math.abs(contentOuter.offsetHeight - contentInner.offsetHeight) && (contentInnerMarginTop = contentInner.offsetHeight - contentOuter.offsetHeight);
					setStyle(dragInner, 'top', dragInnerPosTop + 'px');
					setStyle(contentInner, 'marginTop', -1 * contentInnerMarginTop + 'px');
				}
			}, contentOuterScroll = function(evt) {
				Util.stopEvent(evt);
				// “mousewheel” 事件中的 “event.wheelDelta” 属性值：返回的值，如果是正值说明滚轮是向上滚动，如果是负值说明滚轮是向下滚动；返回的值，均为 120 的倍数，即：幅度大小 = 返回的值 / 120。
				// “DOMMouseScroll” 事件中的 “event.detail” 属性值：返回的值，如果是负值说明滚轮是向上滚动（与 “event.wheelDelta” 正好相反），如果是正值说明滚轮是向下滚动；返回的值，均为 3 的倍数，即：幅度大小 = 返回的值 / 3。
				// “mousewheel” 事件在 Opera 10+ 中却是个特例，既有 “event.wheelDelta” 属性，也有 “event.detail” 属性。
				// distance 滚动距离
				var delta = evt.wheelDelta / 120 || evt.detail / -3,
					distance;
				// 滚动隐去的距离 负数
				var contentInnerOffsetTop = contentInner.offsetTop;
				// 容器高度
				var contOuterHeight =contentOuter.offsetHeight;
				// 内容高度
				var contHeight = contentInner.offsetHeight;
				if (!(Math.abs(delta) > 1)) {

					// 鼠标向上滚动但到尽头了
					if (delta > 0 && contentInnerOffsetTop >= 0) {
						distance = 0;
						return
					}
					if (delta < 0 && contentInnerOffsetTop <= contOuterHeight - contHeight) {
						distance = 0;
						return
					}
					distance = delta * 40;
					delta > 0 && Math.abs(contentInnerOffsetTop) < distance && (distance = delta * Math.abs(contentInnerOffsetTop));
					delta < 0 && Math.abs(contentInnerOffsetTop - (contOuterHeight - contHeight)) < Math.abs(distance) && (distance = delta * Math.abs(contentInnerOffsetTop - (contOuterHeight - contHeight)));
					elmMove(distance, delta)
				}
			}, elmMove = function(distance, delta) {
				var contentInnerMarginTop, dragInnerPosTop;
				contentInnerMarginTop = contentInner.offsetTop + distance;
				setStyle(contentInner, 'marginTop', contentInnerMarginTop + 'px');
				dragInnerPosTop = Math.round(contentInnerMarginTop * dragOuter.offsetHeight / contentInner.offsetHeight);
				setStyle(dragInner, 'top', -1 * dragInnerPosTop + 'px');
				contentInner.offsetTop >= 0 ? dragInner.style.top = '0px' : contentInner.offsetTop <= contentOuter.offsetHeight - contentInner.offsetHeight && (dragInner.style.top = dragOuter.offsetHeight - dragInner.offsetHeight + 'px');
			}, dragEvents = {
				dragStart: function(custEvt, evt) {
					dragStartOffsetY = evt.offsetY;
				},
				draging: function(custEvt, evt) {
					var dragInnerPosTop, contentInnerMarginTop, scrollPos = Util.scrollPos();
					dragInnerPosTop = evt.clientY - dragStartOffsetY - dragInnerPos.t + scrollPos.top;
					if (!(dragInnerPosTop < 0)) {
						if (dragInnerPosTop + dragInner.offsetHeight > dragOuter.offsetHeight) return;
						contentInnerMarginTop = parseInt(dragInnerPosTop * contentInner.offsetHeight / dragOuter.offsetHeight, 10);
						if (contentInnerMarginTop >= Math.abs(contentOuter.offsetHeight - contentInner.offsetHeight)) return;
						setStyle(dragInner, 'top', dragInnerPosTop + 'px');
						setStyle(contentInner, 'marginTop', -1 * contentInnerMarginTop + 'px');
					}
				}
				// dragEnd: function(a, b) {},
				// dragMove: function(a) {
				// 	var contentInnerMarginTop;
				// 	contentInnerMarginTop = contentInner.offsetTop + a - contentOuterPos.t;
				// 	setStyle(contentInner, 'marginTop', contentInnerMarginTop + 'px');
				// }
			}, addContOuterEvent = function(a) {
				Util.addEvent(contentOuter, 'mousewheel', contentOuterScroll, false);
				Util.addEvent(contentOuter, 'DOMMouseScroll', contentOuterScroll, false);
			}, removeContOuterEvent = function(a) {
				Util.removeEvent(contentOuter, 'mousewheel', contentOuterScroll, false);
				Util.removeEvent(contentOuter, 'DOMMouseScroll', contentOuterScroll, false);
			}, destroy = function() {
				removeContOuterEvent();
				_custEvent.remove(drag.getActObj(), 'dragStart', dragEvents.dragStart);
				_custEvent.remove(drag.getActObj(), 'draging', dragEvents.draging);
			}, param = {
				contentOuter: null,
				contentInner: null,
				dragOuter: null,
				dragInner: null
			};
		param = Util.parseParam(param, e);
		var reset = function() {
			if (isMOBILE) {
				setStyle(contentInner, 'height', contentOuter.offsetHeight + 'px');
				setStyle(contentInner, 'minHeight', '');
				setStyle(contentInner, 'overflowY', 'scroll');
				setStyle(dragOuter, 'display', 'none');
				setStyle(dragInner, 'display', 'none');
				destroy()
			} else {
				if (contentInner.offsetHeight <= contentOuter.offsetHeight) {
					setStyle(contentInner, 'marginTop', '0px');
					setStyle(dragInner, 'height', '0px');
					setStyle(dragOuter, 'display', 'none');
					destroy();
					return;
				}
				var dragInnerPosTop;
				setStyle(dragOuter, 'display', 'block');
				contentOuterPos = Util.position(contentOuter);
				dragInnerHeight = parseInt(contentOuter.offsetHeight * dragOuter.offsetHeight / contentInner.offsetHeight, 10);
				setStyle(dragInner, 'height', dragInnerHeight + 'px');
				dragInnerPosTop = -1 * param.contentInner.offsetTop * param.dragOuter.offsetHeight / param.contentInner.offsetHeight;
				param.dragInner.style.top = dragInnerPosTop + 'px';
				dragOuterPos = Util.position(dragOuter);
				if (contentInner.offsetTop <= contentOuter.offsetHeight - contentInner.offsetHeight) {
					setStyle(contentInner, 'marginTop', contentOuter.offsetHeight - contentInner.offsetHeight + 'px');
					setStyle(dragInner, 'top', dragOuter.offsetHeight - dragInner.offsetHeight + 'px');
				}
				removeContOuterEvent();
				addContOuterEvent()
			}
		}, hasParam = function() {
				if (!param.contentOuter || !param.contentInner || !param.dragOuter || !param.dragInner) throw 'node is node defined'
			}, setParam = function() {
				contentOuter = param.contentOuter;
				contentInner = param.contentInner;
				dragOuter = param.dragOuter;
				dragInner = param.dragInner
			}, dragInit = function() {
				drag = Util.drag(dragInner);
				addContOuterEvent();
				_addEvent(dragOuter, 'click', dragOuterClick);
				_custEvent.add(drag.getActObj(), 'dragStart', dragEvents.dragStart);
				_custEvent.add(drag.getActObj(), 'draging', dragEvents.draging)
			}, init = function() {
				isMOBILE = Util.ua.isMOBILE;
				if (isMOBILE) {
					setStyle(contentInner, 'height', contentOuter.offsetHeight + 'px');
					setStyle(contentInner, 'minHeight', '');
					setStyle(contentInner, 'overflowY', 'scroll');
					setStyle(dragOuter, 'display', 'none');
					setStyle(dragInner, 'display', 'none');
					destroy()
				} else {
					if (contentInner.offsetHeight <= contentOuter.offsetHeight) {
						setStyle(dragInner, 'height', '0px');
						setStyle(dragOuter, 'display', 'none');
						destroy();
						return
					}
					setStyle(dragOuter, 'display', 'block');
					setStyle(contentInner, 'marginTop', '0px');
					setStyle(dragInner, 'top', '0px');
					contentOuterPos = Util.position(contentOuter);
					dragOuterPos = Util.position(dragOuter);
					dragInnerPos = Util.position(dragInner);
					dragInnerHeight = Math.round(contentOuter.offsetHeight * dragOuter.offsetHeight / contentInner.offsetHeight);
					setStyle(dragInner, 'height', dragInnerHeight + 'px');
					dragInnerTop = dragInner.offsetTop
				}
			}, ready = function() {
				hasParam();
				setParam();
				dragInit();
				init();
			};
		ready();
		ScrollBar.elmMove = elmMove;
		ScrollBar.init = init;
		ScrollBar.destroy = destroy;
		ScrollBar.reset = reset;
		return ScrollBar;
	}
})();