;(function($) {
    var ua = navigator.userAgent.toLowerCase(); var isIE6 = /msie 6/.test(ua); var extend = function(destination, source) {for (var property in source) {destination[property] = source[property]; } return destination; }; var setStyles = function(ele, styles) {for (property in styles) {ele.style[property] = styles[property]; } }; var getOffset = function(ele) {var top = 0; var left = 0; while (ele != null && ele != document.body) {left += ele.offsetLeft; top += ele.offsetTop; ele = ele.offsetParent; } return {top: top, left: left }; }; var hasClass = function(el, clz) {if (!el) {return false; } return el.className.match(new RegExp('(\\s|^)' + clz + '(\\s|$)')); }; var addClass = function(el, clz) {if (!hasClass(el, clz)) {el.className = el.className.replace(/(^\s*)|(\s*$)/g, '') + ' ' + clz; } }; var removeClass = function(el, clz) {if (hasClass(el, clz)) {var reg = new RegExp('(\\s|^)' + clz + '(\\s|$)'); el.className = el.className.replace(reg, ' '); } }; var addEvent = function(el, evType, func, useCapture) {if (typeof useCapture == 'undefined') {useCapture = false; } if (el.addEventListener) {el.addEventListener(evType, func, useCapture); return true; } else if (el.attachEvent) {el.attachEvent('on' + evType, func); return true; } else {el['on' + evType] = func; } };
    var ScrollFix = function(wrap, config) {
        var defaults = {
            getTop: function(wrap){
                return 0;
            },
            getHeight:function(wrap){
                return wrap.offsetHeight;
            },
            fixed:function(wrap,scrollTop,offsetTop,top){
                return scrollTop > offsetTop-top;
            },
            onFix:function(wrap){

            },
            onUnFix:function(wrap){

            }
        };
        config = extend(defaults, config);
        var pNode = wrap.parentNode;
        var divFilled = document.createElement('div');
        pNode.insertBefore(divFilled, wrap);
        if(isIE6){
            var position = pNode.style.position;
            if(position!=='absolute'&&position!=='relative'){
                setStyles(pNode, {
                    position:'relative'
                });
            }
        }
        var fixedClz = config.fixedClz||'fixed';
        var toggle = function(b) {
            var height = '1px';
            var marginTop = '-1px';
            if (b) {
                height = config.getHeight(wrap) + 'px';
                marginTop = 0;
            }
            setStyles(divFilled, {
                height:height,
                marginTop:marginTop,
                overflow:'hidden'
            });
        };
        var scrollHandle = function() {
            var offsetTop = getOffset(divFilled).top;
            var scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
            var top = config.getTop(wrap)||0;
            if (config.fixed(wrap,scrollTop, offsetTop,top)) {
                toggle(true);
                addClass(wrap, fixedClz);

                if(isIE6){
                    top = top+scrollTop- getOffset(pNode).top;
                }
                setStyles(wrap,{
                    top:top+'px'
                });
                config.onFix(wrap);
            } else {
                toggle(false);
                removeClass(wrap, fixedClz);
                config.onUnFix(wrap);
            }
        }
        var timerId = null;
        addEvent(window, 'scroll', function() {
            if (!timerId) {
                scrollHandle();
                timerId = true;
            } else {
                clearTimeout(timerId);
                setTimeout(function() {
                    scrollHandle();
                }, 100);
            }
        });
        scrollHandle();
    };
    window.ScrollFix = ScrollFix;
})();