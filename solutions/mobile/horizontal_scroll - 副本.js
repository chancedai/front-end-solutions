// 20141218185211
(function(exports,undefined){
        var noop = function(){};
        var isFn = function(fn){
            return typeof fn === 'function';
        };
        var Touch = function(wrap,opt){
            var self = this;
            self.wrap = wrap;
            self.opt = $.extend({
                move:function(px){},
                // 在哪个方向不使用touchmove事件 v,h
                keepDirection:'',
                left:noop,
                right:noop,
                up:noop,
                down:noop,
                start:noop,
                end:noop
            },opt);
        };
        Touch.prototype = {
            init:function(){
                var self = this;
                self.iPadStatus = 'ok';
                self.bindEvent();
            },
            touchstart : function(e){
                var self  = this;
                self.iPadX = e.touches[0].pageX;
                self.iPadY = e.touches[0].pageY;
                self.iPadScrollX = exports.pageXOffset;
                self.iPadScrollY = exports.pageYOffset; //用于判断页面是否滚动
                self.startTime = (new Date()).getTime();
                self.opt.start();
            },
            touchend : function(e){
                var self  = this;
                var opt = self.opt;
                if(self.iPadStatus != 'touch'){return};
                self.iPadStatus = 'ok';
                //self._state = 'ready';
                var cX = self.iPadX - self.iPadLastX;
                var cY = self.iPadY - self.iPadLastY;
                var time = (new Date()).getTime()-self.startTime;
                var rate = cX/cY;
                if(cX<0){
                    opt.left(cX,time,rate);
                }else{
                    opt.right(cX,time,rate);
                }
                if(cY<0){
                    opt.down(cY,time,rate);
                }else{
                    opt.up(cY,time,rate);
                }
                opt.end(cX,cY);
            },
            bindEvent:function(){
                // if(typeof(exports.ontouchstart) === 'undefined'){
                //  return;
                // }
                var self = this;
                var opt = self.opt;
                var wrap = self.wrap;
                if(wrap.length === 0){
                    return;
                }

                wrap.on('touchstart',function(e){
                    self.touchstart(e);
                });
                wrap.on('touchmove',function(e){
                    if(event.touches.length > 1){ //多点触摸
                        touchend();
                    };
                    self.iPadLastX = event.touches[0].pageX;
                    var cX = self.iPadX - self.iPadLastX;

                    self.iPadLastY = event.touches[0].pageY;
                    var cY = self.iPadY - self.iPadLastY;

                    if(self.iPadStatus == 'ok'){
                        if(self.iPadScrollY == exports.pageYOffset && self.iPadScrollX == exports.pageXOffset && Math.abs(cX)>20){ //横向触摸
                            self.iPadStatus = 'touch';
                        }else if(self.iPadScrollX == exports.pageXOffset && self.iPadScrollY == exports.pageYOffset && Math.abs(cY)>20){
                            self.iPadStatus = 'touch';
                        }else{
                            return;
                        };
                    };

                    if(Math.abs(cX) < Math.abs(cY)&&opt.keepDirection==='v'){
                       opt.move(cX,cY);
                       event.preventDefault();
                       return;
                    }
                    if(Math.abs(cX) > Math.abs(cY)&&opt.keepDirection==='h'){
                       opt.move(cX,cY);
                       event.preventDefault();
                       return;
                    }
                    opt.move(cX,cY);
                    event.preventDefault();
                });
                wrap.on('touchend',function(e){
                    self.touchend(e);
                });
            }
        };
    var hScroll = function(wrap,opt){
        var self = this;
        self.wrap = wrap;
        self.inner = wrap.children();
        self.opt = opt||{};
        self.cont = self.inner.children();

    };
    hScroll.prototype = {
        init:function(){
            var self = this;
            if(!self.opt.maxWidth){
                self.inner.css({
                    width:'9999px'
                });
            }
            self.left = self.opt.left||0;
            var contWidth = 0;
            var wrapWidth = 0;
            if(!self.opt.wrapWidth){
                wrapWidth = self.wrap.width();
            }else{
                wrapWidth = self.opt.wrapWidth;
            }
            if(!self.opt.contWidth){
                self.cont.css({
                    width:'auto'
                });
                contWidth = self.cont.width();

            }else{
                contWidth = self.opt.width;
            }
            self.inner.css({
                width:contWidth +'px'
            });
            if(!self.Touch){
                self.Touch = new Touch(self.wrap, {
                    keepDirection:'v',
                    start:function(x,y){

                    },
                    end:function(x,y){
                        self.left = self.getLeftOffest(x);
                    },
                    move:function(x,y){
                        self.move(x,y);
                    }
                });
                self.Touch.init();
            }

            self.contWidth = contWidth;
            self.wrapWidth = wrapWidth;
        },
        getLeftOffest:function(x){
            var self = this;
            var lastLeft = self.left;
            var left = lastLeft-x;
            left = Math.max(left, -self.contWidth+self.wrapWidth);
            left = Math.min(left,0);
            return left;
        },
        move:function(x){
            var self = this;
            var left = self.getLeftOffest(x);
            var opt = self.opt;
            if(left === -self.contWidth+self.wrapWidth){
                if(isFn(opt.onEnd)){
                    opt.onEnd();
                }
            }
            if(left === 0){
                if(isFn(opt.onStart)){
                    opt.onStart();
                }
            }
            self.inner.css({
                left:left+'px'
            });
        },
        reset:function(){
            var self = this;
            self.init();
            self.left = self.getLeftOffest(0);
            self.inner.css({
                left:self.left+'px'
            });
        }
    };
    exports.hScroll = hScroll;

})(window);