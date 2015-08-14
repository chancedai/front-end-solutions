(function(win, doc) {
    var $thirdFuns = function() {
        return function() {
            var empty = function() {};
            var that = {
                playVideo: empty,
                setAutoPlay: empty,
                setPid: empty,
                resetParam: empty
            };
            var funObjects = {};
            that.on = function(type, fun) {
                if (!funObjects[type]) {
                    funObjects[type] = [];
                }
                funObjects[type].push(fun);
            };
            that.trigger = function(type, data) {
                var funList = funObjects[type];
                if (funList) {
                    var length = funList.length;
                    for (var i = 0; i < length; i++) {
                        try {
                            funList[i].apply(null, [data]);
                        } catch (e) {}
                    }
                }
            };
            return that;
        };
    }();;


    var SVKFlashUtil = function(win, doc) {
        var that = {},
            UNDEF = "undefined",
            nav = win.navagator;
        var UNDEF = "undefined",
            OBJECT = "object",
            SHOCKWAVE_FLASH = "Shockwave Flash",
            SHOCKWAVE_FLASH_AX = "ShockwaveFlash.ShockwaveFlash",
            FLASH_MIME_TYPE = "application/x-shockwave-flash",
            EXPRESS_INSTALL_ID = "SWFObjectExprInst",
            ON_READY_STATE_CHANGE = "onreadystatechange",
            nav = navigator,
            plugin = false,
            ua = function() {
                var w3cdom = typeof doc.getElementById != UNDEF && typeof doc.getElementsByTagName != UNDEF && typeof doc.createElement != UNDEF,
                    u = nav.userAgent.toLowerCase(),
                    p = nav.platform.toLowerCase(),
                    windows = p ? /win/.test(p) : /win/.test(u),
                    mac = p ? /mac/.test(p) : /mac/.test(u),
                    webkit = /webkit/.test(u) ? parseFloat(u.replace(/^.*webkit\/(\d+(\.\d+)?).*$/, "$1")) : false,
                    ie = !+"1",
                    playerVersion = [0, 0, 0],
                    d = null;
                if (typeof nav.plugins != UNDEF && typeof nav.plugins[SHOCKWAVE_FLASH] == OBJECT) {
                    d = nav.plugins[SHOCKWAVE_FLASH].description;
                    if (d && !(typeof nav.mimeTypes != UNDEF && nav.mimeTypes[FLASH_MIME_TYPE] && !nav.mimeTypes[FLASH_MIME_TYPE].enabledPlugin)) {
                        plugin = true;
                        ie = false;
                        d = d.replace(/^.*\s+(\S+\s+\S+$)/, "$1");
                        playerVersion[0] = parseInt(d.replace(/^(.*)\..*$/, "$1"), 10);
                        playerVersion[1] = parseInt(d.replace(/^.*\.(.*)\s.*$/, "$1"), 10);
                        playerVersion[2] = /[a-zA-Z]/.test(d) ? parseInt(d.replace(/^.*[a-zA-Z]+(.*)$/, "$1"), 10) : 0;
                    }
                } else if (typeof win.ActiveXObject != UNDEF) {
                    try {
                        var a = new ActiveXObject(SHOCKWAVE_FLASH_AX);
                        if (a) {
                            d = a.GetVariable("$version");
                            if (d) {
                                ie = true;
                                d = d.split(" ")[1].split(",");
                                playerVersion = [parseInt(d[0], 10), parseInt(d[1], 10), parseInt(d[2], 10)];
                            }
                        }
                    } catch (e) {}
                }
                return {
                    // w3: w3cdom,
                    // pv: playerVersion,
                    wk: webkit,
                    ie: ie,
                    win: windows,
                    mac: mac
                };
            }();
        var createFlashHTML = function(attObj, parObj) {
                if (ua.ie && ua.win) {
                    var att = "",
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
                url: "",
                id: "vPlayer",
                width: 640,
                height: 480,
                flashvars: {},
                params: {
                    allowNetworking: "all",
                    allowScriptAccess: "always",
                    wmode: "transparent",
                    allowFullScreen: "true",
                    quality: "high",
                    bgcolor: "#000000"
                },
                attributes: {}
            };
            opts = $parseParam(opts, args);
            var att = {},
                par = {};
            att.data = opts.url;
            att.width = opts.width + "";
            att.height = opts.height + "";
            att.id = opts.id;
            for (var i in opts.attributes) {
                att[i] = opts.attributes[i];
            }
            for (var i in opts.params) {
                par[i] = opts.params[i];
            }
            par.flashvars = "";
            for (var i in opts.flashvars) {
                if (par.flashvars) {
                    par.flashvars += "&" + i + "=" + opts.flashvars[i];
                } else {
                    par.flashvars = i + "=" + opts.flashvars[i];
                }
            }
            return createFlashHTML(att, par);
        };
        that.isSupport = function() {};
        that.isSupportVersion = function(minVersion) {};
        return that;
    }(window, document);;


    var $thirdFlashPlayer = function() {
        return function(config) {
            var that = $thirdFuns(),
                init, bindFuns;
            var _this = {
                dom: false
            };
            var initDOM = function() {
                var container = document.getElementById(config.container);
                container.innerHTML = SVKFlashUtil.getFlashHTML(config);
            };
            bindFuns = function() {
                for (var i in that) {
                    if (i != "on" && i != "trigger") {
                        bind(i);
                    }
                }
            };
            init = function() {
                initDOM();
                _this.dom = document.getElementById(config.id);
                bindFuns();
            };
            var bind = function(name) {
                that[name] = function() {
                    _this.dom[name].apply(_this.dom, arguments);
                };
            };
            var globalfuns = ["flashInitCompleted", "playCompleted"];
            var resetWinName = function(name, temp) {
                window[name] = function() {
                    that.trigger(name);
                    temp();
                };
            };
            for (var i = 0; i < globalfuns.length; i++) {
                var funName = globalfuns[i];
                var temp = window[funName] || function() {};
                resetWinName(funName, temp);
            }
            that.destroy = function() {
                _this.dom = false;
            };
            that.init = init;
            return that;
        };
    }();;



    var $videoUtil = function() {
        return function(config) {
            return ['<video id="' + config.id + '" src="" controls="" preload="" style="width: ' + config.width + "px; height: " + config.height + 'px;" poster="' + (config.thumbUrl || "") + '">', "</video>"].join("");
        };
    }();;


    var $utilJsonp = function() {
        var uniqueKey = (new Date).getTime();
        return function(url, callback) {
            var head = document.getElementsByTagName("head")[0] || document.documentElement;
            var script = document.createElement("script");
            var callbackName = "HTML5_" + uniqueKey++;
            script.src = url + "&callback=" + callbackName;
            script.charset = "utf-8";
            window[callbackName] = function(json) {
                if (callback || typeof callback === "function") {
                    callback(json);
                    delete window[callback];
                    head.removeChild(script);
                }
            };
            head.appendChild(script);
        };
    }();;


    var $addEvent = function() {
        return function(el, type, fn) {
            if (el == null) {
                return false;
            }
            if (typeof fn !== "function") {
                return false;
            }
            if (el.addEventListener) {
                el.addEventListener(type, fn, false);
            } else if (el.attachEvent) {
                el.attachEvent("on" + type, fn);
            } else {
                el["on" + type] = fn;
            }
            return true;
        };
    }();;


    var $thirdHTML5Player = function() {
        return function(config) {
            var that = $thirdFuns(),
                init, bindFuns, bindListener;
            var _this = {
                dom: false
            };
            var initDOM = function() {
                var container = document.getElementById(config.container);
                container.innerHTML = $videoUtil(config);
            };
            bindFuns = function() {
                var playVideoBySrc = function(videoId) {
                    var src = "http://v.iask.com/v_play_ipad.php?vid=" + videoId;
                    _this.dom.src = src;
                };
                var vidGetIpadIdUrl = "http://video.sina.com.cn/interface/video_ids/video_ids.php?v=";
                that.playVideo = function(vid, uid, ad, videoId) {
                    if (videoId) {
                        playVideoBySrc(videoId);
                    } else {
                        $utilJsonp(vidGetIpadIdUrl + vid, function(json) {
                            playVideoBySrc(json.ipad_vid);
                        });
                    }
                };
            };
            bindListener = function() {
                $addEvent(_this.dom, "ended", function() {
                    that.trigger("playCompleted");
                });
            };
            init = function() {
                initDOM();
                _this.dom = document.getElementById(config.id);
                bindFuns();
                bindListener();
                that.trigger("flashInitCompleted");
            };
            that.destroy = function() {
                _this.dom = false;
            };
            that.init = init;
            return that;
        };
    }();;

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
            url: "http://p.you.video.sina.com.cn/swf/bokePlayer20130516_V4_1_42_11.swf",
            width: 640,
            height: 516,
            id: "myMovie",
            name: "myMovie",
            params: {
                allowNetworking: "all",
                allowScriptAccess: "always",
                wmode: "transparent",
                allowFullScreen: "true",
                quality: "high",
                bgcolor: "#000000"
            },
            container: "myflashBox",
            flashvars: {
                pid: "1",
                tid: "334",
                autoLoad: "1",
                as: "1",
                lightBtn: "0",
                popBtn: "0",
                wideBtn: "0",
                tj: "0",
                head: "0",
                continuePlayer: "1",
                actlogActive: "0",
                realfull: "1",
                moz: "1"
            }
        };
        if (!opt) {
            return null;
        }
        opt = clone(opt);
        var homeConfig = ["id", "name", "width", "height", "container"];
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
    var sinaVideoPlayer = function(param) {
        var _this = {
            param: {}
        };
        _this.param = parseParam(param);
        if (!_this.param) {
            throw "没有传入初始化参数";
        }
        var that = null;
        var initThat = function() {
            var ua = navigator.userAgent.toLowerCase();
            if (ua.match(/ipad/i) || ua.match(/ipod/i) || ua.match(/iphone/i)) {
                that = $thirdHTML5Player(_this.param);
            } else {
                that = $thirdFlashPlayer(_this.param);
            }
        };
        initThat();
        return that;
    };
    var sinaVideoPlayerClient = function(param) {
        var config = parseParam(param);
        var _this = {},
            that = {};
        that.addVars = function(name, value) {
            config.flashvars[name] = value;
        };
        that.showFlashPlayer = function() {
            _this.flashObject = sinaVideoPlayer(config);
            _this.flashObject.init();
            return _this.flashObject;
        };
        that.getPlayer = function() {
            return _this.flashObject;
        };
        return that;
    };
    win.sinaVideoPlayerClient = sinaVideoPlayerClient;
    win.sinaVideoPlayer = sinaVideoPlayer;
    if (window.sinaBokePlayerConfig_o) {
        var SinaBokePlayer_o = sinaVideoPlayerClient(window.sinaBokePlayerConfig_o);
        window.SinaBokePlayer_o = SinaBokePlayer_o;
        window.__onloadFun__ && window.__onloadFun__();
    }
})(window, document);