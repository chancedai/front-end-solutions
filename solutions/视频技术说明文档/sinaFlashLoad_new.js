(function(win, doc) {
    var noop = function() {};
    var byId = function(id) {
        return document.getElementById(id);
    };
    var jsonp = function() {
        var uniqueKey = (new Date).getTime();
        return function(url, callback) {
            var head = document.getElementsByTagName('head')[0] || document.documentElement;
            var script = document.createElement('script');
            var callbackName = 'HTML5_' + uniqueKey++;
            script.src = url + '&callback=' + callbackName;
            script.charset = 'utf-8';
            window[callbackName] = function(json) {
                if (callback || typeof callback === 'function') {
                    callback(json);
                    delete window[callback];
                    head.removeChild(script);
                }
            };
            head.appendChild(script);
        };
    }();
    var createVideo = function() {
        return function(config) {
            return ['<video id="' + config.id + '" src="" controls="" preload="" style="width: ' + config.width + "px; height: " + config.height + 'px;" poster="' + (config.thumbUrl || "") + '">', '</video>'].join('');
        };
    }();
    var createFlashVideo = function(win, doc) {
        var that = {};
        var nav = win.navigator,
            FLASH_MIME_TYPE = 'application/x-shockwave-flash';
        var ua = function() {
            var ua = nav.userAgent.toLowerCase(),
                platform = nav.platform.toLowerCase(),
                windows = platform ? /win/.test(platform) : /win/.test(ua),
                mac = platform ? /mac/.test(platform) : /mac/.test(ua),
                webkit = /webkit/.test(ua) ? parseFloat(ua.replace(/^.*webkit\/(\d+(\.\d+)?).*$/, "$1")) : false,
                ie = !+"1";
            return {
                wk: webkit,
                ie: ie,
                win: windows,
                mac: mac
            };
        }();
        var createFlashHTML = function(attObj, parObj) {
                if (ua.ie && ua.win) {
                    var att = '',
                        parObj = parObj || {};
                    for (var i in attObj) {
                        if (attObj[i] != Object.prototype[i]) {
                            if (i.toLowerCase() == "data") {
                                parObj.movie = attObj[i];
                            } else if (i.toLowerCase() == "styleclass") {
                                att += ' class="' + attObj[i] + '"';
                            } else if (i.toLowerCase() != "classid") {
                                att += " " + i + '="' + attObj[i] + '"';
                            }
                        }
                    }
                    var par = "";
                    for (var j in parObj) {
                        if (parObj[j] != Object.prototype[j]) {
                            par += '<param name="' + j + '" value="' + parObj[j] + '" />';
                        }
                    }
                    return '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"' + att + ">" + par + "</object>";
                } else {
                    var _html = '<embed pluginspage="http://www.macromedia.com/go/getflashplayer" type="' + FLASH_MIME_TYPE + '" ';
                    for (var i in attObj) {
                        if (attObj[i] != Object.prototype[i]) {
                            if (i.toLowerCase() == "data") {
                                _html += 'src="' + attObj[i] + '" ';
                            } else if (i.toLowerCase() == "styleclass") {
                                _html += ' class="' + attObj[i] + '" ';
                            } else if (i.toLowerCase() != "classid") {
                                _html += " " + i + '="' + attObj[i] + '" ';
                            }
                        }
                    }
                    for (var n in parObj) {
                        _html += n + '="' + parObj[n] + '" ';
                    }
                    _html += "/>";
                    return _html;
                }
            },
            $parseParam = function(oSource, oParams, isown) {
                var key, obj = {};
                oParams = oParams || {};
                for (key in oSource) {
                    obj[key] = oSource[key];
                    if (oParams[key] != null) {
                        if (isown) {
                            if (oSource.hasOwnProperty[key]) {
                                obj[key] = oParams[key];
                            }
                        } else {
                            obj[key] = oParams[key];
                        }
                    }
                }
                return obj;
            };
        that.getFlashHTML = function(args) {
            var opts = {
                url: '',
                id: 'vPlayer',
                width: 640,
                height: 480,
                flashvars: {},
                params: {
                    allowNetworking: 'all',
                    allowScriptAccess: 'always',
                    wmode: 'transparent',
                    allowFullScreen: 'true',
                    quality: 'high',
                    bgcolor: '#000000'
                },
                attributes: {}
            };
            opts = $parseParam(opts, args);
            var att = {},
                par = {};
            att.data = opts.url;
            att.width = opts.width + '';
            att.height = opts.height + '';
            att.id = opts.id;
            for (var i in opts.attributes) {
                att[i] = opts.attributes[i];
            }
            for (var i in opts.params) {
                par[i] = opts.params[i];
            }
            par.flashvars = '';
            for (var i in opts.flashvars) {
                if (par.flashvars) {
                    par.flashvars += '&' + i + '=' + opts.flashvars[i];
                } else {
                    par.flashvars = i + '=' + opts.flashvars[i];
                }
            }
            return createFlashHTML(att, par);
        };
        return that;
    }(window, document);
    var clone = function(jsonObj) {
        var buf;
        if (jsonObj instanceof Array) {
            buf = [];
            var i = jsonObj.length;
            while (i--) {
                buf[i] = clone(jsonObj[i]);
            }
            return buf;
        } else if (jsonObj instanceof Object) {
            buf = {};
            for (var k in jsonObj) {
                buf[k] = clone(jsonObj[k]);
            }
            return buf;
        } else {
            return jsonObj;
        }
    };
    var parseParam = function(opt) {
        var config = {
            url: 'http://p.you.video.sina.com.cn/swf/bokePlayer20130516_V4_1_42_11.swf',
            width: 640,
            height: 516,
            id: 'myMovie',
            name: 'myMovie',
            params: {
                allowNetworking: 'all',
                allowScriptAccess: 'always',
                wmode: 'transparent',
                allowFullScreen: 'true',
                quality: 'high',
                bgcolor: '#000000'
            },
            container: 'myflashBox',
            flashvars: {
                pid: '1',
                tid: '334',
                autoLoad: '1',
                as: '1',
                lightBtn: '0',
                popBtn: '0',
                wideBtn: '0',
                tj: '0',
                head: '0',
                continuePlayer: '1',
                actlogActive: '0',
                realfull: '1',
                moz: '1'
            }
        };
        if (!opt) {
            return null;
        }
        opt = clone(opt);
        var homeConfig = ['id', 'name', 'width', 'height', 'container'];
        for (var i = 0; i < homeConfig.length; i++) {
            var name = homeConfig[i];
            if (opt[name]) {
                config[name] = opt[name];
                delete opt[name];
            }
        }
        for (var i in opt) {
            config.flashvars[i] = opt[i];
        }
        return config;
    };
    var Clz = function(parent) {
        var propertyName = '___ytreporp___';
        var klass = function() {
            this.init.apply(this, arguments);
        };
        if (parent) {
            var Subclass = noop;
            Subclass.prototype = parent.prototype;
            klass.prototype = new Subclass();
        }
        klass.prototype.init = noop;
        klass.fn = klass.prototype;
        klass.fn.parent = klass;
        klass._super = klass.__proto__;
        klass.extend = function(obj) {
            var extended = obj.extended;
            for (var i in obj) {
                klass[i] = obj[i];
            }
            if (extended) {
                extended(klass);
            }
        };
        klass.include = function(obj) {
            var included = obj.included;
            for (var i in obj) {
                klass.fn[i] = obj[i];
            }
            if (included) {
                included(klass);
            }
        };
        return klass;
    };
    var CustomEvent = new Clz();
    CustomEvent.include({
        init: function() {
            this.fnsObj = {};
        },
        on: function(type, fun) {
            var fnsObj = this.fnsObj;
            if (!fnsObj[type]) {
                fnsObj[type] = [];
            }
            fnsObj[type].push(fun);
        },
        trigger: function(type, data) {
            var fnsObj = this.fnsObj;
            var funList = fnsObj[type];
            if (funList) {
                var length = funList.length;
                for (var i = 0; i < length; i++) {
                    try {
                        funList[i].apply(null, [data]);
                    } catch (e) {}
                }
            }
        }
    });

    var FlashPlayer = new Clz(CustomEvent);
    FlashPlayer.include({
        init: function(config) {
            this.fnsObj = {};
            this.type = 'flash';
            config = parseParam(config);
            this.config = config;
        },
        initialization: function() {
            var self = this;
            var config = self.config;
            var container = byId(config.container);
            container.innerHTML = createFlashVideo.getFlashHTML(config);
            self.dom = byId(config.id);
            self.bindFlashFns();
        },
        bindFlashFns: function() {
            var self = this;
            // falsh对象提供的方法
            var fns = ['playVideo', 'setAutoPlay', 'setPid', 'resetParam', 'jsPlay', 'jsStop', 'jsPause'];
            var bind = function(name) {
                var newName = name;
                // 'jsPlay', 'jsStop', 'jsPause'--> play,stop,pause
                if (name.indexOf('js') === 0) {
                    newName = name.replace('js', '').toLowerCase();
                }
                self[newName] = function() {
                    self.dom[name].apply(self.dom, arguments);
                };
            };
            for (var i = 0, len = fns.length; i < len; i++) {
                var item = fns[i];
                bind(item);
            }
            // falsh暴露的全局方法
            var globalfns = ['flashInitCompleted', 'playCompleted'];
            var resetWinName = function(name, temp) {
                window[name] = function() {
                    // 给全局函数加功能
                    self.trigger(name);
                    temp();
                };
            };
            for (var i = 0, len = globalfns.length; i < len; i++) {
                var name = globalfns[i];
                var temp = window[name] || function() {};
                resetWinName(name, temp);
            }
        }

    });

    var addEvent = function(el, type, fn) {
        if (el == null) {
            return false;
        }
        if (typeof fn !== 'function') {
            return false;
        }
        if (el.addEventListener) {
            el.addEventListener(type, fn, false);
        } else if (el.attachEvent) {
            el.attachEvent('on' + type, fn);
        } else {
            el['on' + type] = fn;
        }
        return true;
    };

    var HTML5Player = new Clz(CustomEvent);
    HTML5Player.include({
        init: function(config) {
            this.fnsObj = {};
            this.type = 'html5';
            config = parseParam(config);
            this.config = config;
        },
        initialization: function() {
            var self = this;
            var config = self.config;
            var container = byId(config.container);
            container.innerHTML = createVideo(config);
            self.dom = byId(config.id);
            self.bindVideoFns();
            self.trigger('flashInitCompleted');
        },
        bindVideoFns: function() {
            var self = this;
            var vidGetIpadIdUrl = "http://video.sina.com.cn/interface/video_ids/video_ids.php?v=";
            var playVideoBySrc = function(videoId) {
                var src = "http://v.iask.com/v_play_ipad.php?vid=" + videoId;
                self.dom.src = src;
            };
            self.playVideo = function(vid, uid, ad, videoId) {
                if (videoId) {
                    playVideoBySrc(videoId);
                } else {
                    jsonp(vidGetIpadIdUrl + vid, function(json) {
                        playVideoBySrc(json.ipad_vid);
                    });
                }
            };
            // video对象提供的方法
            var fns = ['play', 'stop', 'pause'];
            var bind = function(name) {
                self[name] = function() {
                    self.dom[name].apply(self.dom, arguments);
                };
            };
            for (var i = 0, len = fns.length; i < len; i++) {
                var item = fns[i];
                bind(item);
            }

            addEvent(self.dom, 'ended', function() {
                self.trigger('playCompleted');
            });
        }

    });

    var SinaVideoPlayer;
    var ua = navigator.userAgent.toLowerCase();
    if (ua.match(/ipad/i) || ua.match(/ipod/i) || ua.match(/iphone/i)) {
        SinaVideoPlayer = HTML5Player;
    } else {
        SinaVideoPlayer = FlashPlayer;
    }
    win.SinaVideoPlayer = SinaVideoPlayer;
})(window, document);