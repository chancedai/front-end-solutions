(function(exports, undefined) {
	var Clz = function(parent) {
		var slice = [].slice;
		var noop = function() {};
		// 新建类，init为构造函数入口
		var klass = function() {
			this.init.apply(this, arguments);
		};
		klass.superclass = parent;
		klass.subclasses = [];
		// 如果存在父类就需要继承
		if (parent) {
			//新建一个空类用以继承，其存在的意义是不希望构造函数被执行
			//比如 klass.prototype = new parent;就会执行其init方法
			var subclass = function() {};
			subclass.prototype = parent.prototype;
			klass.prototype = new subclass;
			parent.subclasses.push(klass);
		}

		if (!klass.prototype.init) {
			klass.prototype.init = noop;
		}

		klass.prototype.constructor = klass;

		klass.fn = klass.prototype;
		klass.fn.parent = klass;

		klass.proxy = function(func) {
			var self = this;
			return (function() {
				return func.apply(self, func);
			});
		}

		klass.fn.proxy = klass.proxy;
		// 给类添加属性
		klass.extend = function(obj) {
			var extended = obj.extended;
			for (var i in obj) {
				klass[i] = obj[i];
			}
			// 回调
			if (extended) {
				extended(klass);
			}
		};
		// 给实例添加属性
		klass.include = function(obj) {

			var included = obj.included;
			// for (var i in obj) {
			//     klass.fn[i] = obj[i];
			// }
			var ancestor = klass.superclass && klass.superclass.prototype;
			for (var k in obj) {
				var value = obj[k];

				//满足条件就重写
				if (ancestor && typeof value == 'function') {
					var argslist = /^\s*function\s*\(([^\(\)]*?)\)\s*?\{/i.exec(value.toString())[1].replace(/\s/i, '').split(',');
					//只有在第一个参数为$super情况下才需要处理（是否具有重复方法需要用户自己决定）
					if (argslist[0] === '$super' && ancestor[k]) {
						value = (function(methodName, fn) {
							return function() {
								var scope = this;
								var args = [function() {
									return ancestor[methodName].apply(scope, arguments);
								}];
								return fn.apply(this, args.concat(slice.call(arguments)));
							};
						})(k, value);
					}
				}

				klass.prototype[k] = value;
			}
			// 回调
			if (included) {
				included(klass);
			}
		};

		return klass;
	};
	var getNodes = function(wrap, attr) {
		attr = attr || 'node-type';
		wrap = $(wrap);
		var nodes = $("[" + attr + "]", wrap);
		var nodesObj = {};
		nodesObj.wrap = wrap;
		nodes.each(function(i) {
			var item = $(this);
			nodesObj[item.attr(attr)] = item;
		});
		return nodesObj;
	};
	var Inner = new Clz();
	Inner.include({
		init:function(opts){
			var self = this;
			var opts = self.opts = $.extend({
				wrap:'',
				data:{},
				// 默认设置
				typekey:'feder-type'
			},opts);
			var wrap = self.wrap = $(opts.wrap);
			// 渲染
			self.html();
			self.install.call(self);
		},
		setOpts:function(k,v){
			var i = 0,
				opts = this['opts'],
				ns = k.split('.'),
				len = ns.length,
				upp = len - 1,
				key;
			for (var i = 0, len = ns.length; i < len; i++) {
				key = ns[i];
				if (i == upp) {
					opts[key] = v;
				}
				if (opts[key] === undefined) {
					opts[key] = {};
				}
				opts = opts[key];
			}
			this.html();
		},
		on:function(){
			// this.wrap.on.apply(this.wrap,arguments);
		},
		off:function(){
			// this.wrap.off.apply(this.wrap,arguments);
		},
		bind:function(){
			var self = this;
			self.wrap.on('input','[]');
		},
		render:function(){
		},
		html:function(){
			var self = this;
			var tpl = self.render.call(self)||'';
			var html = Mustache.render(tpl, self.opts.data);
			self.wrap.html(html);
			self.dom = getNodes(self.wrap,self.opts.typekey);
		},
		install:function(){}
	});
	var Feder = {
		create:function(){
			var inner,opts;
			if(arguments.length===2){
				inner = arguments[0];
				opts = arguments[1];
			}else{
				inner = Inner;
				opts = arguments[0];
			}
			var I = new Clz(Inner);
			I.include(opts);
			return I;
		}
	};
	exports.Feder = Feder;

})(window);