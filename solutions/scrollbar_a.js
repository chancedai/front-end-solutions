;
(function(exports) {
	var Util = {
		ua: (function() {
			var ua = navigator.userAgent.toLowerCase();
			var test = function(re) {
				return re.test(ua);
			};
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
		byId: function(id) {
			return document.getElementById(id);
		},
		byAttr:function(node, attname, attvalue){
			if(typeof node=='string'){
				node = Util.byId(node);
			}
			var nodes = [];
			attvalue = attvalue||'';
			var getAttr = function(node){
					return node.getAttribute(attname);
				};
			for(var i = 0, l = node.childNodes.length; i < l; i ++){
				if(node.childNodes[i].nodeType == 1){
					var fit = false;
					if(attvalue){
						fit = (getAttr(node.childNodes[i]) == attvalue);
					}else{
						fit = (getAttr(node.childNodes[i]) !='')
					}
					if(fit){
						nodes.push(node.childNodes[i]);
					}
					if(node.childNodes[i].childNodes.length > 0){
						nodes = nodes.concat(arguments.callee.call(null, node.childNodes[i], attname, attvalue));
					}
				}
			}
			return nodes;
		},
		builder:function(wrap, type) {
			var list, nodes,ids;
			wrap = (function(){
				if(typeof wrap == 'string'){
					return Util.byId(wrap);
				}
				return wrap;
			})();
			nodes = this.byAttr(wrap,type);
			list = {};
			ids = {};
			for(var i = 0, len = nodes.length; i < len; i++) {
				var j = nodes[i].getAttribute(type);
				if(!j){
					continue;
				}
				list[j] || (list[j] = []);
				list[j].push(nodes[i]);
				ids[j] || (ids[j]=nodes[i]);
			}
			return {
				box: wrap,
				list: list,
				ids: ids
			};
		},
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
			var getMax = Math.max;
			return {
				top: getMax(dd.scrollTop, db.scrollTop),
				left: getMax(dd.scrollLeft, db.scrollLeft),
				width: getMax(dd.scrollWidth, db.scrollWidth),
				height: getMax(dd.scrollHeight, db.scrollHeight)
			};
		},
		getPos: function(ele) {
			var x = 0;
			var y = 0;
			while (ele != null) {
				x += ele.offsetLeft;
				y += ele.offsetTop;
				ele = ele.offsetParent;
			}
			return {
				t: y,
				l: x
			};
		}
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
								}].concat(args));
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
		var _cancelBubble = function(evt) {
			evt.cancelBubble = true;
			return false
		};
		var objClone = function(nObj, oObj) {
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
				actObj: {}
			}, config);
			var Drag = {};
			var custEventObj = _custEvent.define(param.actObj, 'dragStart');
			var custEventObjEnd = _custEvent.define(param.actObj, 'dragEnd');
			var custEventObjDraging = _custEvent.define(param.actObj, 'draging');
			var _mouseDown = function(evt) {
				var oEvt = objClone({}, evt);
				doc.body.onselectstart = function() {
					return false;
				};
				_addEvent(doc, 'mousemove', _mouseMove);
				_addEvent(doc, 'mouseup', _mouseUp);
				// TODO 会阻止其它绑定在doc上面的事件
				// _addEvent(doc, 'click', _cancelBubble, true);
				if (!Util.ua.isIE) {
					evt.preventDefault();
					evt.stopPropagation();
				}
				_custEvent.fire(custEventObj, 'dragStart', oEvt);
				return false;
			};
			var _mouseMove = function(evt) {
				var oEvt = objClone({}, evt);
				evt.cancelBubble = true;
				_custEvent.fire(custEventObj, 'draging', oEvt)
			};
			var _mouseUp = function(evt) {
				var oEvt = objClone({}, evt);
				doc.body.onselectstart = function() {
					return true;
				};
				Util.removeEvent(doc, 'mousemove', _mouseMove);
				Util.removeEvent(doc, 'mouseup', _mouseUp);
				Util.removeEvent(doc, 'click', _cancelBubble, true);
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
	exports.ScrollBarT = (function(){
		var _addEvent = Util.addEvent;
		var _custEvent = Util.custEvent;
		var _getPos = Util.getPos;
		var _isMOBILE = Util.ua.isMOBILE;
		var setStyle = function(ele, pros) {
			if (ele) {
				for(var i in pros){
					ele.style[i] = pros[i];
				}
			}
			return ele;
		};
		var ScrollBar = function(wrap){
			var self = this;
			self.init(wrap);
		};
		ScrollBar.prototype = {
			init:function(wrap){
				var self = this;
				var builder = Util.builder(wrap,'scroll-type');
				var ids = builder.ids;
				self.node = {
					wrap:wrap,
					cont:ids.cont,
					bar:ids.bar,
					trigger:ids.trigger
				};
				self.status = {
					wrapPos:{
						left:0,
						top:0
					},
					triggerPos:{
						left:0,
						top:0
					},
					dragStartOffsetY:0,
					triggerHeight:0,
					triggerTop:0
				};
				self.dragInit();
				self.render();
			},
			setStatus:function(key,val){
				var self = this;
				self.status = self.status||{};
				self.status[key] = val;
			},
			getStatus:function(key){
				var self = this;
				self.status = self.status||{};
				return self.status[key];
			},
			dragInit:function(){
				var self = this;
				var wrap = self.node.wrap;
				var cont = self.node.cont;
				var bar = self.node.bar;
				var trigger = self.node.trigger;
				var dragEvents = {
					dragStart: function(custEvt, evt) {
						self.setStatus('dragStartOffsetY',evt.offsetY);
					},
					draging: function(custEvt, evt) {
						var scrollPos = Util.scrollPos();
						var triggerPos = self.getStatus('triggerPos');
						var triggerPosTop = evt.clientY - self.getStatus('dragStartOffsetY') - triggerPos.t + scrollPos.top;
						if (triggerPosTop >= 0) {
							if(triggerPosTop + trigger.offsetHeight > bar.offsetHeight){
								return;
							}
							var contMarginTop = parseInt(triggerPosTop * cont.offsetHeight / bar.offsetHeight, 10);
							if (contMarginTop >= Math.abs(wrap.offsetHeight - cont.offsetHeight)){
								return;
							}
							setStyle(trigger, {
								'top': triggerPosTop + 'px'
							});
							setStyle(cont,{
								'marginTop': -1 * contMarginTop + 'px'
							});
						}
					}
				};
				self.drag = Util.drag(self.node.trigger);
				self.dragEvents = dragEvents;
				self.addContOuterEvent();
				_addEvent(bar, 'click', function(evt){
					self.barClick(evt);
				});
				_custEvent.add(self.drag.getActObj(), 'dragStart', dragEvents.dragStart);
				_custEvent.add(self.drag.getActObj(), 'draging', dragEvents.draging);
			},
			barClick: function(evt) {
				var self = this;
				var node = self.node;

				var wrap = node.wrap;
				var cont = node.cont;
				var bar = node.bar;
				var trigger = node.trigger;

				var evt = Util.fixEvent(evt);
				var	target = evt.target;
				var barPos = _getPos(bar);
				var triggerPosTop = evt.clientY - barPos.t;
				if (triggerPosTop>0&&target != trigger) {
					var contMarginTop = parseInt(triggerPosTop * cont.offsetHeight / bar.offsetHeight, 10);
					if(contMarginTop >= Math.abs(wrap.offsetHeight - cont.offsetHeight)){
						contMarginTop = cont.offsetHeight - wrap.offsetHeight;
					}
					if(triggerPosTop + trigger.offsetHeight > bar.offsetHeight){
					 	triggerPosTop = bar.offsetHeight - trigger.offsetHeight;
					}
					setStyle(trigger, 'top', triggerPosTop + 'px');
					setStyle(cont, 'marginTop', -1 * contMarginTop + 'px');
				}
			},
			wrapScroll : function(evt) {
				var self = this;
				var wrap = self.node.wrap;
				var cont = self.node.cont;
				Util.stopEvent(evt);
				// “mousewheel” 事件中的 “event.wheelDelta” 属性值：返回的值，如果是正值说明滚轮是向上滚动，如果是负值说明滚轮是向下滚动；返回的值，均为 120 的倍数，即：幅度大小 = 返回的值 / 120。
				// “DOMMouseScroll” 事件中的 “event.detail” 属性值：返回的值，如果是负值说明滚轮是向上滚动（与 “event.wheelDelta” 正好相反），如果是正值说明滚轮是向下滚动；返回的值，均为 3 的倍数，即：幅度大小 = 返回的值 / 3。
				// “mousewheel” 事件在 Opera 10+ 中却是个特例，既有 “event.wheelDelta” 属性，也有 “event.detail” 属性。
				// distance 滚动距离
				var delta = evt.wheelDelta / 120 || evt.detail / -3;
				var	distance = 0;
				// 滚动隐去的距离 负数
				var contOffsetTop = cont.offsetTop;
				// 容器高度
				var contOuterHeight = wrap.offsetHeight;
				// 内容高度
				var contHeight = cont.offsetHeight;
				if (!(Math.abs(delta) > 1)) {

					// 鼠标向上滚动但到尽头了
					if (delta > 0 && contOffsetTop >= 0) {
						return
					}
					if (delta < 0 && contOffsetTop <= contOuterHeight - contHeight) {
						return
					}
					distance = delta * 40;
					delta > 0 && Math.abs(contOffsetTop) < distance && (distance = delta * Math.abs(contOffsetTop));
					delta < 0 && Math.abs(contOffsetTop - (contOuterHeight - contHeight)) < Math.abs(distance) && (distance = delta * Math.abs(contOffsetTop - (contOuterHeight - contHeight)));
					self.setPos(distance)
				}
			},
			setPos:function(distance){
				var self = this;
				var wrap = self.node.wrap;
				var cont = self.node.cont;
				var bar = self.node.bar;
				var trigger = self.node.trigger;
				var contMarginTop = cont.offsetTop + distance;
				setStyle(cont,{
					'marginTop':contMarginTop + 'px'
				});
				var triggerPosTop = Math.round(contMarginTop * bar.offsetHeight / cont.offsetHeight);
				triggerPosTop = -1 * triggerPosTop + 'px';
				var contOffsetTop = cont.offsetTop;
				if(contOffsetTop >= 0){
					triggerPosTop = '0px';
				}else{
					if(contOffsetTop <= wrap.offsetHeight - cont.offsetHeight){
						triggerPosTop = bar.offsetHeight - trigger.offsetHeight + 'px';
					}
				}
				setStyle(trigger, {
					'top': triggerPosTop
				});
			},
			addContOuterEvent: function(a) {
				var self = this;
				var wrap = this.node.wrap;
				Util.addEvent(wrap, 'mousewheel', function(evt){
					self.wrapScroll(evt);
				}, false);
				Util.addEvent(wrap, 'DOMMouseScroll', function(evt){
					self.wrapScroll(evt);
				}, false);
			},
			removeContOuterEvent: function(a) {
				var self = this;
				var wrap = this.node.wrap;
				Util.removeEvent(wrap, 'mousewheel', function(evt){
					self.wrapScroll(evt);
				}, false);
				Util.removeEvent(wrap, 'DOMMouseScroll', function(evt){
					self.wrapScroll(evt);
				}, false);
			},
			destroy :function() {
				var self = this;
				var drag = self.drag;
				self.removeContOuterEvent();
				_custEvent.remove(drag.getActObj(), 'dragStart', dragEvents.dragStart);
				_custEvent.remove(drag.getActObj(), 'draging', dragEvents.draging);
			},
			render:function(){
				var self = this;
				var node = self.node;
				var wrap = node.wrap;
				var cont = node.cont;
				var bar = node.bar;
				var trigger = node.trigger;
				if (_isMOBILE) {
					setStyle(cont,{
						'height': wrap.offsetHeight + 'px',
						'minHeight': '',
						'overflowY': 'scroll'
					});
					setStyle(bar,{
						display:'none'
					});
					setStyle(trigger,{
						display:'none'
					});
					destroy();
				} else {
					if (cont.offsetHeight <= wrap.offsetHeight) {
						setStyle(trigger, {
							'height':'0px'
						});
						setStyle(bar, {
							'display':'none'
						});
						destroy();
						return
					}
					setStyle(bar, {
						'display':'block'
					});
					setStyle(cont, {
						'marginTop':'0px'
					});
					setStyle(trigger, {
						'top':'0px'
					});
					self.setStatus('wrapPos',_getPos(wrap));
					self.setStatus('barPos',_getPos(bar));
					self.setStatus('triggerPos',_getPos(trigger));
					self.setStatus('triggerHeight',Math.round(wrap.offsetHeight * bar.offsetHeight / cont.offsetHeight));
					setStyle(trigger, {
						'height':self.getStatus('triggerHeight') + 'px'
					});
					self.setStatus('triggerTop',trigger.offsetTop);
				}
			}
		};
		return ScrollBar;
	})();

})(window);