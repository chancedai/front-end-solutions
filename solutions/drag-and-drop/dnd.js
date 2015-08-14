
(function(con) {
    // the dummy function
    function dummy() {};
    for (var methods = ['error', 'info', 'log', 'warn', 'clear'], func; func = methods.pop();) {
        con[func] = con[func] || dummy;
    }
}(window.console = window.console || {}));
console = window.console;
(function($) {
    var PREFIX = 'dNd';
    var noop = function() {};
    var ovarlayId = PREFIX+'_' + (new Date()).getTime();
    var docBody = document.body;
    var $doc = $(document);
    var PX = 'px';
    var hasIntersect = function(drag,drop,mousePos){
        var getPos = function(ele){
            var offset = ele.offset();
            var width = ele.outerWidth();
            var height = ele.outerHeight();
            return {
                min:{
                    x:offset.left,
                    y:offset.top
                },
                mouse:{
                    x:offset.left+width*mousePos.left,
                    y:offset.top+height*mousePos.top
                },
                max:{
                    x:offset.left+width,
                    y:offset.top+height
                }
            };
        };
        var getArea = function(pos){
            var width = pos.max.x-pos.min.x;
            var height = pos.max.y-pos.min.y;
            if(width<0||height<0){
                return 0;
            }
            return width*height;
        };
        var dragPos = getPos(drag);
        var dropItem = null;
        var area = 0;
        var dist = 0;
        drop.each(function(){
            var item = $(this);
            var itemPos = getPos(item);
            var intersect ={
                min:{},
                max:{}
            };
            intersect.min.x = Math.max(itemPos.min.x, dragPos.min.x);
            intersect.min.y = Math.max(itemPos.min.y, dragPos.min.y);
            intersect.max.x = Math.min(itemPos.max.x, dragPos.max.x);
            intersect.max.y = Math.min(itemPos.max.y, dragPos.max.y);

            dist = itemPos.min.y-dragPos.mouse.y;
            var intersectArea = getArea(intersect);
            if(intersectArea>0&&(intersectArea>area)){
                dropItem = item;
                area = intersectArea;
            }
        });
        return {
            dropItem:dropItem,
            dist:dist
        }
    };
    $.fn.dNd = function(opt, callback) {
        var defaults = {
            speed: 400,
            interval: 300,
            easing: null,
            cursor: 'move',
            // 范围
            range: null,
            // 手柄
            handle: null,
            overlay: true,
            dropItems:'',
            replace:noop,
            hover:noop,
            drop:noop,
            stop: noop,
            moving: noop,
            start: noop,
            afterEachAnimation: function(e) {}
        }
        if (typeof callback == 'function') {
            defaults.stop = callback;
        }
        opt = $.extend(defaults, opt || {});
        return this.each(function() {
            var intervalId, startX, startY, draggableStartX, draggableStartY, dragging = false,
                evt, draggable = this,
                $draggable = $(this);
            //手柄
            var handle = $draggable.find(opt.handle);
            if (handle.length === 0) {
                handle = $draggable;
            }
            // 范围
            var getLimit = function(){
                var $range = $(opt.range);
                var top = $range.offset().top;
                var left = $range.offset().left;
                var bottom = top + $range.innerHeight();
                var right = left + $range.innerWidth();
                return {
                    top:top,
                    left:left,
                    bottom:bottom,
                    right:right
                };
            };
            if(opt.range){
                var limit = getLimit();
                $(window).on('resize',function(){
                    limit = getLimit();
                });
            }

            var lastDropItem = null;
            var dropItem = null;
            // drag和drop距离
            var maxDist = 1;
            var dist = 0;
            // 鼠标在drag上的位置
            var mousePos = {
                top:0,
                left:0
            };
            handle.attr('dNd','inited');
            handle.on('mousedown',function(e) {
                if(handle.attr('dNd-draggable')==='false'){
                    return;
                }
                opt.start.call(draggable, e);
                var lastX, lastY;
                dragging = true;

                evt = e;

                startX = lastX = e.pageX;
                startY = lastY = e.pageY;
                draggableStartX = $draggable.offset().left;
                draggableStartY = $draggable.offset().top;

                $draggable.css({
                    position: 'absolute',
                    left: draggableStartX + PX,
                    top: draggableStartY + PX,
                    cursor: opt.cursor,
                    zIndex: '1010'
                }).addClass(PREFIX+'-drag').appendTo(docBody);
                if (opt.overlay && $('#' + ovarlayId).length == 0) {
                    $('<div id="' + ovarlayId + '"></div>').css({
                        position: 'absolute',
                        top: '0',
                        left: '0',
                        zIndex: '1000',
                        width: $(docBody).outerWidth() + PX,
                        height: $(docBody).outerHeight() + PX
                    }).appendTo(docBody);
                } else if (opt.overlay) {
                    $('#' + ovarlayId).show();
                }
                var getMousePos = function(outerWidth,outerHeight){
                    if(mousePos.top==0&&mousePos.lfet!==0){
                       var posLeft = Math.max((startX - draggableStartX)/outerWidth, 0);
                       var posTop = Math.max((startY - draggableStartY)/outerHeight, 0);
                       mousePos = {
                           left:Math.min(posLeft,1),
                           top:Math.min(posTop,1)
                       };
                    }

                };
                intervalId = setInterval(function() {
                    if (lastX != evt.pageX || lastY != evt.pageY) {
                        var outerWidth = $draggable.outerWidth();
                        var outerHeight = $draggable.outerHeight();
                        var positionX = draggableStartX - (startX - evt.pageX),
                            positionY = draggableStartY - (startY - evt.pageY);

                        getMousePos(outerWidth,outerHeight);
                        if(opt.range){
                            if (positionX < limit.left) {
                                positionX = limit.left;
                            } else if (positionX + $draggable.innerWidth() > limit.right) {
                                positionX = limit.right - outerWidth;
                            }
                            if (positionY < limit.top) {
                                positionY = limit.top;
                            } else if (positionY + $draggable.innerHeight() > limit.bottom) {
                                positionY = limit.bottom - outerHeight;
                            }
                        }
                        $draggable.stop().animate({
                            left: positionX + PX,
                            top: positionY + PX
                        }, opt.speed, opt.easing, function() {
                            opt.afterEachAnimation.call(draggable, evt);
                        });

                        if(opt.dropItems){
                            var $dropItems = $(opt.dropItems);
                            var info =  hasIntersect($draggable,$dropItems,mousePos);
                            dropItem = info.dropItem;
                            dist = info.dist;
                            dist = Math.max(0,dist);
                            maxDist = Math.max(dist, maxDist);
                        }
                    }
                    lastX = evt.pageX;
                    lastY = evt.pageY;
                }, opt.interval);
                // ($.browser && $.browser.safari || e.preventDefault());
            });
            $doc.on('mousemove',function(e) {
                if (!dragging) {
                    return;
                }
                evt = e;
                opt.moving.apply(draggable, [e,dropItem,lastDropItem,dist/maxDist,mousePos]);
                lastDropItem = dropItem;
            });
            $doc.on('mouseup',function(e) {
                if (!dragging) {
                    return;
                }
                $draggable.css({
                    cursor: '',
                    zIndex: '990'
                }).removeClass(PREFIX+'-drag');
                $('#' + ovarlayId).hide().appendTo(docBody);
                clearInterval(intervalId);
                mousePos = {
                    top:0,
                    left:0
                };
                opt.stop.call(draggable, e);
                opt.drop.apply(draggable,[e,dropItem]);
                dragging = false;
            });
        });
    }
})(jQuery);