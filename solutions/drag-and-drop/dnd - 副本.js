
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
    var hasIntersect = function(drag,drop){
        var getPos = function(ele){
            var offset = ele.offset();
            return {
                min:{
                    x:offset.left,
                    y:offset.top
                },
                max:{
                    x:offset.left+ele.outerWidth(),
                    y:offset.top+ele.outerHeight()
                }
            };
            // 上右下左
            return [offset.top,offset.left+ele.outerWidth(),offset.top+ele.outerHeight(),offset.left];
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
        console.log(drop);
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
            var intersectArea = getArea(intersect);
            if(intersectArea>0&&(intersectArea>area)){
                dropItem = item;
                area = intersectArea;
            }
        });
        return dropItem;
    };
    $.fn.dNd = function(opt, callback) {
        var defaults = {
            speed: 400,
            interval: 300,
            easing: null,
            cursor: 'move',
            // 范围
            range: docBody,
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
            var range = opt.range;
            var $range = $(range);
            var limitTop = $range.offset().top,
                limitLeft = $range.offset().left,
                limitBottom = limitTop + $range.innerHeight(),
                limitRight = limitLeft + $range.innerWidth();

            var lastDropItem = null;
            var dropItem = null;
            handle.attr('dNd','inited');
            handle.on('mousedown',function(e) {
                opt.start.call(draggable, e);

                draggable = opt.replace.call(draggable);
                $draggable = $(draggable);

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
                intervalId = setInterval(function() {
                    if (lastX != evt.pageX || lastY != evt.pageY) {
                        var positionX = draggableStartX - (startX - evt.pageX),
                            positionY = draggableStartY - (startY - evt.pageY);

                        if (positionX < limitLeft) {
                            positionX = limitLeft;
                        } else if (positionX + $draggable.innerWidth() > limitRight) {
                            positionX = limitRight - $draggable.outerWidth();
                        }
                        if (positionY < limitTop) {
                            positionY = limitTop;
                        } else if (positionY + $draggable.innerHeight() > limitBottom) {
                            positionY = limitBottom - $draggable.outerHeight();
                        }
                        $draggable.stop().animate({
                            left: positionX + PX,
                            top: positionY + PX
                        }, opt.speed, opt.easing, function() {
                            opt.afterEachAnimation.call(draggable, evt);
                        });

                        if(opt.dropItems){
                            var $dropItems = $(opt.dropItems);
                            console.log($dropItems);
                            dropItem =  hasIntersect($draggable,$dropItems);

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
                opt.moving.apply(draggable, [e,dropItem,lastDropItem]);
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
                opt.stop.call(draggable, e);
                opt.drop.apply(draggable,[e,dropItem]);
                dragging = false;
            });
        });
    }
})(jQuery);