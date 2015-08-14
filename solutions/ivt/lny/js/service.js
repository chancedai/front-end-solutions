(function(win){
   var doc = document;
   var ua = navigator.userAgent.toLowerCase();
   var isIE = /msie/.test(ua);
   var isIE6 = /msie 6/.test(ua);
   var byId = function(id) {
       if (typeof id === 'string') {
           return doc.getElementById(id);
       }
       return id;
   };
   var byTag = function(tag){
       if (typeof tag === 'string') {
           return doc.getElementsByTagName(tag);
       }
       return tag;
   };
   var byAttr = function(node, attname, attvalue) {
       if (typeof node == 'string') {
           node = byId(node);
       }
       var nodes = [];
       attvalue = attvalue || '';
       var getAttr = function(node) {
           return node.getAttribute(attname);
       };
       for (var i = 0, l = node.childNodes.length; i < l; i++) {
           if (node.childNodes[i].nodeType == 1) {
               var fit = false;
               if (attvalue) {
                   fit = (getAttr(node.childNodes[i]) == attvalue);
               } else {
                   fit = !! getAttr(node.childNodes[i]);
               }
               if (fit) {
                   nodes.push(node.childNodes[i]);
               }
               if (node.childNodes[i].childNodes.length > 0) {
                   nodes = nodes.concat(arguments.callee.call(null, node.childNodes[i], attname, attvalue));
               }
           }
       }
       return nodes;
   };
   var getWinSize = function(_target) {
       var w, h;
       if (_target) {
           target = _target.document;
       } else {
           target = document;
       }

       if (target.compatMode === "CSS1Compat") {
           w = target.documentElement["clientWidth"];
           h = target.documentElement["clientHeight"];
       } else if (self.innerHeight) { // all except Explorer
           if (_target) {
               target = _target.self;
           } else {
               target = self;
           }
           w = target.innerWidth;
           h = target.innerHeight;

       } else if (target.documentElement && target.documentElement.clientHeight) { // Explorer 6 Strict Mode
           w = target.documentElement.clientWidth;
           h = target.documentElement.clientHeight;

       } else if (target.body) { // other Explorers
           w = target.body.clientWidth;
           h = target.body.clientHeight;
       }
       return {
           width: w,
           height: h
       };
   };
   var builder = function(wrap, type) {
       var list, nodes,ids;
       wrap = (function(){
           if(typeof wrap == 'string'){
               return byId(wrap);
           }
           return wrap;
       })();
       nodes = byAttr(wrap,type);
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
   };
   var removeNode = function(el){
       if(el&&el.parentNode){
           el.parentNode.removeChild(el);
       }
   }
   var setStyle = function(el,styles){
       if(!el){
           return;
       }
       for(var i in styles){
           el.style[i] = styles[i];
       }
   };
   var addEvent = function(el, type, fn, useCapture) {
       if (!el) {
           return
       }
       if (typeof useCapture === 'undefined') {
           useCapture = false;
       }
       if (el.addEventListener) {
           el.addEventListener(type, fn, useCapture);
           return true;
       } else if (el.attachEvent) {
           el.attachEvent('on' + type, fn);
           return true;
       } else {
           el['on' + type] = fn;
       }
   };
   var isFunction = function(fn) {
       return typeof fn === 'function';
   };
   var extend = function(destination, source) {
       for (var property in source) {
           destination[property] = source[property];
       }
       return destination;
   };
   var Mask = function(config){
       var self = this;
       var defaults = {
           opacity:0.3,
           zIndex:1e4,
           overlayClz:'overlay-clz'
       };
       config = extend(defaults, config);
       self.config = config;
       self.overlay = null;
       self.visible = false;
       self._create();
   };
   Mask.prototype = {
       _create: function(){
           var self = this;
           var config = self.config;
           opacity = config.opacity;
          if(self.overlay){
              return;
          }
          var ieOpacity = opacity*100;
          var iframe;
          var hackDiv;
          var overlay = doc.createElement('div');
          overlay.className = config.overlayClz;
          setStyle(overlay,{
              zIndex:config.zIndex,
              left:'0px',
              top:'0px',
              width:'100%',
              height:'100%',
              position:'fixed',
              backgroundColor:'#000',
              filter:'Alpha(Opacity='+ieOpacity+')',
              opacity:opacity
          });
          if(isIE){
              iframe = doc.createElement('iframe');
              iframe.frameBorder=0;
              iframe.scrolling='no';
              setStyle(iframe,{
                  filter : 'Alpha(Opacity=0)',
                  width : '100%',
                  height : '100%'
              });
              setStyle(overlay,{
                  filter:'Alpha(Opacity='+ieOpacity+')'
              });
              overlay.appendChild(iframe);
              // 添加一个div遮盖iframe,用于绑定关闭事件
              hackDiv = doc.createElement('div');
              setStyle(hackDiv,{
                  left:'0px',
                  top:'0px',
                  width:'100%',
                  height:'100%',
                  position:'absolute'
              });
              overlay.appendChild(hackDiv);
          }
          if(isIE6){
               // 先append 否则css expression不起作用
               doc.body.appendChild(overlay);
               for (var i in {
                   Top: 1,
                   Left: 1
               }){
                   overlay.style.setExpression(i.toLowerCase(), "(_=(document.documentElement.scroll" + i + " || document.body.scroll" + i + "))+'px'");
               }
               setStyle(overlay,{
                   position:'absolute'
               });
               setStyle(doc.body,{
                   width:'100%',
                   height:'100%'
               });
          }else{
              doc.body.appendChild(overlay);
          }
          self.overlay = overlay;
          self.iframe = iframe;
      },
     on:function(){
       var self = this;
         setStyle(self.overlay,{
             display:'block'
         });
         self.visible = true;
     },
     off:function(){
       var self = this;
         setStyle(self.overlay,{
             display:'none'
         });
         self.visible = false;
     },
     isVisible:function(){
         return visible;
     }
   };
   var Dialog = function(html,config){
       var self = this;
       var defaults = {
           mask:true,
           opacity:0.3,
           modal:false,
           zIndex:1e4,
           overlayClz:'overlay-clz',
           boxClz:'box-clz',
           scroll:true,
           getWidth:function(){
               // 如果offsetWidth不准确，可以自定义些方法获取 width
               var wrap = this.dom.ids.wrap;
               return wrap.offsetWidth;
           },
           getHeight:function(){
               // 如果offsetHeight不准确，可以自定义些方法获取 height
               var wrap = this.dom.ids.wrap;
               return wrap.offsetHeight;
           }
       };
       self.isVisible = false;
       self.config = extend(defaults, config||{});
       self._render(html);
   };
   Dialog.prototype = {
       _render:function(html){
           var self = this;
           var config = self.config;
           // 创建半透明层
           if(config.mask){
               self.mask = new Mask({
                   opacity:config.opacity,
                   zIndex:config.zIndex-1,
                   overlayClz:config.overlayClz
               });
           }

           if(!self.box){
               self.box = doc.createElement('div');
               self.box.className = config.boxClz;
               setStyle(self.box,{
                   display:'none',
                   zIndex:config.zIndex
               });
               doc.body.appendChild(self.box);
           }
           self.box.innerHTML = html||'';
           var dom = builder(self.box,'dialog-type');
           self.dom = dom;
           if(isFunction(config.afterRender)){
               config.afterRender.call(self);
           }
           // 绑定事件
           self._bind();
       },
       _bind:function(){
           var self = this;
           var config = self.config;
           var ids = self.dom.ids;
           addEvent(ids.close,'click',function(){
               if(isFunction(config.onClose)){
                   config.onClose.call(self);
               }
               self.hide();
           });
           addEvent(ids.confirm,'click',function(){
               if(isFunction(config.onConfirm)){
                   config.onConfirm.call(self);
               }
           });
           addEvent(ids.cancel,'click',function(){
               if(isFunction(config.onCancel)){
                   config.onCancel.call(self);
               }
               if(isFunction(config.onClose)){
                   config.onClose.call(self);
               }
               self.hide();
           });
           // 点击窗口外区域关闭
           if((!config.modal) && config.mask){
               addEvent(self.mask.overlay,'click',function(){
                   self.hide();
               });
           }
       },
       show:function(html){
           var self = this;
           var config = self.config;
           if(!self.box){
               self.box = doc.createElement('div');
           }
           var box = self.box;
           if(config.width){
               setStyle(box,{
                   width:config.width
               });
           }
           if(config.height){
               setStyle(box,{
                   height:config.height
               });
           }
           setStyle(box,{
               display:''
           });
           self.isVisible = true;
           if(config.mask){
               self.mask.on();
           }
           if(!self.config.scroll){
             setStyle(doc.body,{
               overflow:'hidden'
             });
           }
           self.center();
           if(isFunction(config.onShow)){
               config.onShow.call(self);
           }
       },
       hide:function(){
           var self = this;
           var config = self.config;
           if(!self.box){
               self.box = doc.createElement('div');
           }
           var box = self.box;
           if(config.width){
               setStyle(box,{
                   width:config.width+'px'
               });
           }
           if(config.height){
               setStyle(box,{
                   height:config.height+'px'
               });
           }
           setStyle(box,{
               display:'none'
           });
           self.isVisible = false;
           if(config.mask){
               self.mask.off();
           }
           if(!self.config.scroll){
             setStyle(doc.body,{
               overflow:'auto'
             });
           }
           if(isFunction(config.onHide)){
               config.onHide.call(self);
           }
       },
       center:function(){
           // 支持两种定位模式，fixed(不跟随页面滚动)，absolute(跟随页面滚动)
           var self = this;
           var config = self.config;
           if(!self.isVisible){
               return;
           }
           var px = 'px';
           var winSize = getWinSize();
           var scrollTop = document.body.scrollTop || document.documentElement.scrollTop;
           var position = config.position||'fixed';
           var left,top,marginLeft,marginTop;

           left = '50%';
           marginLeft = -(config.getWidth.call(self)/2)+px;
           marginTop = -(config.getHeight.call(self)/2)+px;

           if(position==='absolute'){
               top = (winSize.height/2 + scrollTop)+px;
           }else{
               top = '50%';
           }
           setStyle(self.box,{
               position:position,
               left:left,
               top:top,
               marginLeft:marginLeft,
               marginTop:marginTop
           });
           self.box.style.marginLeft = marginLeft;
           if(isIE6&&position==='fixed'){
               self.box.style.setExpression('top',"_=(document.documentElement.scrollTop || document.body.scrollTop) + Math.round(50 * (document.documentElement.offsetHeight || document.body.clientHeight) / 100) + 'px'");
               setStyle(self.box,{
                   position:'absolute'
               });
           }
       },
       destory:function(){
           var self = this;
           removeNode(self.box);
           if(config.mask){
               removeNode(self.mask.overlay);
           }
           self = null;
       }
   };
   win.__Dialog__ = Dialog;
})(window);

;(function() {
	var NODEATTR = 'node-type';
	var getNodes = function(wrap) {
		var attr = NODEATTR || 'node-type';
		wrap = $(wrap);
		var nodes = $('[' + attr + ']', wrap);
		var nodesObj = {};
		nodesObj.wrap = wrap;
		nodes.each(function(i) {
			var item = $(this);
			nodesObj[item.attr(attr)] = item;
		});
		return nodesObj;
	};



  var AddHtml = ['<div class="dialog dialog-add" dialog-type="wrap">',
                    '<div class="hd">',
                        '<h3>添加客服号</h3>',
                        '<a href="javascript:;" dialog-type="close" class="close">关闭</a>',
                    '</div>',
                    '<div class="bd">',
                        '<ul class="post-wrap">',
                          '<li class="post-item post-head" id="js_add_wrap">',
                            '<label>头像</label>',
                            '<div class="post-img">',
                                '<img src="img/avatar-small.png" dialog-type="kf_headimgurl" width="45" height="45" alt=""/>',
                            '</div>',
                            '<p class="post-tip"><a dialog-type="kf_uploadbtn" href="javascript:;">上传头像</a>(jpg格式，建议大小：640*640) <strong id="js_add_progress"></strong></p>',
                            '<input type="hidden" name="id" dialog-type="kf_id"/>',
                          '</li>',
                          '<li class="post-item post-email">',
                            '<label>工号</label>',
                            '<input type="text" name="email" dialog-type="kf_account" placeholder="请输入登录账号">',
                            '<p class="post-txt">@i1000moons_bluetooth</p>',
                            '<p class="post-tip">工号不能重复，一旦输入不能修改，由字母及数字组成</p>',
                          '</li>',
                          '<li class="post-item post-name">',
                            '<label>昵称</label>',
                            '<input type="text" name="name" dialog-type="kf_nick" placeholder="请输入昵称">',
                            '<p class="post-tip"></p>',
                          '</li>',
                          '<li class="post-item post-password">',
                            '<label>密码</label>',
                            '<input type="password" name="password" dialog-type="kf_password" placeholder="请输入密码">',
                            '<p class="post-tip">请输入6-16位密码</p>',
                          '</li>',
                        '</ul>',
                    '</div>',
                    '<div class="ft">',
                        '<a href="javascript:;" dialog-type="confirm" class="btn confirm">确认添加</a>',
                        '<a href="javascript:;" dialog-type="cancel" class="btn btn-gray cancel">取消</a>',
                    '</div>',
                '</div>'].join('');
  var DialogAdd = null;

  var EditHtml = ['<div class="dialog dialog-add" dialog-type="wrap">',
                    '<div class="hd">',
                        '<h3>修改客服号</h3>',
                        '<a href="javascript:;" dialog-type="close" class="close">关闭</a>',
                    '</div>',
                    '<div class="bd">',
                        '<ul class="post-wrap">',
                          '<li class="post-item post-head">',
                            '<label>头像</label>',
                            '<div class="post-img">',
                                '<img src="img/avatar-small.png" dialog-type="kf_headimgurl" width="45" height="45" alt=""/>',
                            '</div>',
                            '<p class="post-tip"><a href="javascript:;" dialog-type="kf_uploadbtn" >上传头像</a>(jpg格式，建议大小：640*640)</p>',
                            '<input type="hidden" name="id" dialog-type="kf_id"/>',
                          '</li>',
                          '<li class="post-item post-email">',
                            '<label>工号</label>',
                            '<input type="text" name="email" dialog-type="kf_account" placeholder="请输入登录账号" disabled="true">',
                            '<p class="post-txt">@i1000moons_bluetooth</p>',
                            '<p class="post-tip">工号不能重复，一旦输入不能修改，由字母及数字组成</p>',
                          '</li>',
                          '<li class="post-item post-name">',
                            '<label>昵称</label>',
                            '<input type="text" name="name" dialog-type="kf_nick" placeholder="请输入昵称">',
                            '<p class="post-tip"></p>',
                          '</li>',
                          '<li class="post-item post-password">',
                            '<label>密码</label>',
                            '<input type="password" name="password" dialog-type="kf_password" placeholder="请输入密码">',
                            '<p class="post-tip">请输入6-16位密码</p>',
                          '</li>',
                        '</ul>',
                    '</div>',
                    '<div class="ft">',
                        '<a href="javascript:;" dialog-type="confirm" class="btn confirm">确认修改</a>',
                        '<a href="javascript:;" dialog-type="cancel" class="btn btn-gray cancel">取消</a>',
                    '</div>',
                '</div>'].join('');
  var DialogEdit = null;

  var DelHtml = ['<div class="dialog dialog-add" dialog-type="wrap">',
                    '<div class="hd">',
                        '<h3>删除客服号</h3>',
                        '<a href="javascript:;" dialog-type="close" class="close">关闭</a>',
                    '</div>',
                    '<div class="bd">',
                        '<p>删除后不能恢复，确定要删除？</p>',
                    '</div>',
                    '<div class="ft">',
                        '<a href="javascript:;" dialog-type="confirm" class="btn confirm">确认删除</a>',
                        '<a href="javascript:;" dialog-type="cancel" class="btn btn-gray cancel">取消</a>',
                    '</div>',
                '</div>'].join('');
  var DialogDel = null;

  var dom = getNodes('#js_page_service');
  var TableControler = function(){
      var wrap = null;
      var body = null;
      var hasData = false;
      var getItem = function(item){
          item.kf_headimgurl = item.kf_headimgurl||'img/avatar-small.jpg';
          return ['<tr item-id="'+item.kf_id+'">',
              '<td class="service">',
                  '<div class="pic">',
                      '<img src="'+item.kf_headimgurl+'" height="45" width="45" alt="'+item.kf_nick+'">',
                  '</div>',
                  '<div class="txt">',
                      '<p class="name">'+item.kf_nick+'</p>',
                      '<p class="info">'+item.kf_account+'</p>',
                  '</div>',
                  '<input type="hidden" name="password" value="'+item.kf_password+'"/>',
              '</td>',
              '<td class="edit">',
                  '<a href="javascript:;">修改</a>',
              '</td>',
              '<td class="delete">',
                  '<a href="javascript:;">删除</a>',
              '</td>',
          '</tr>'].join('');

      };
      return {
        init:function(w){
          wrap = w;
          body = $('tbody',wrap);
        },
        list:function(items){
          var html = [];
          var len = items.length;
          if(len>0){
            for (var i = 0; i < len; i++) {
              var item = items[i];
              html.push(getItem(item));
              hasData = true;
            }
          }else{
            html.push('<tr><td class="service" colspan="3"><div class="list-tip">还没有服务号，请添加！</div></td></tr>');
            hasData = false;
          }
          body.html(html.join(''));
        },
        add:function(item){
          if(!hasData){
            body.empty();
          }
          body.append($(getItem(item)));
        },
        edit:function(item){
          // var item = $('[item-id="'+id+'"]',wrap);
          // item.insertAter($(getItem(item)));
          // item.remove();
         this.setData(item);
        },
        remove:function(id){
          var item = $('[item-id="'+id+'"]',wrap);
          item.remove();
          if($('tr',wrap).length===0){
            this.list([]);
          }
        },
        getData:function(id){
          // 获取表格数据
          var tr = $('[item-id="'+id+'"]',wrap);
          return {
            kf_id:id,
            kf_headimgurl:$('img',tr).attr('src'),
            kf_nick:$('.name',tr).html(),
            kf_account:$('.info',tr).html(),
            kf_password:$('[name=password]',tr).val()
          };
        },
        setData:function(item){
          var tr = $('[item-id="' + item.kf_id + '"]', wrap);
          $('img', tr).attr('src', item.kf_headimgurl);
          $('.name', tr).html(item.kf_nick);
          $('.info', tr).html(item.kf_account);
          $('[name=password]', tr).val(item.kf_password);
        }
      };
  }();
  TableControler.init(dom.list);

    // $.ajax({
    //     url:'',
    //     type:'GET',
    //     before:function(){
    //     },
    //     success:function(data,status){
    //          TableControler.list(data);
    //     }
    //   });
  TableControler.list(PAGEDATA.services);

  var DialogControler = function(){
      return {
        getData:function(dom){
          return {
            kf_id:$(dom.kf_id).val(),
            kf_headimgurl:$(dom.kf_headimgurl).attr('src'),
            kf_nick:$(dom.kf_nick).val(),
            kf_account:$(dom.kf_account).val(),
            kf_password:$(dom.kf_password).val()
          };
        },
        setData:function(dom,item){
          console.log(dom,item);
          $(dom.kf_id).val(item.kf_id);
          $(dom.kf_headimgurl).attr('src',item.kf_headimgurl);
          $(dom.kf_account).val(item.kf_account);
          $(dom.kf_nick).val(item.kf_nick);
          $(dom.kf_password).val(item.kf_password);
        }
      };
  }();
  // 提交器
  var UploaderControler = (function(){
     var Uploader1 = null;
     var button = null;
     var image = null;
     var id = 0;
     return {
        init:function(btn,img){
            if(Uploader1){
                Uploader1.stop();
                Uploader1.destroy();
                Uploader1 = null;
            }
            id++;
            btn.id = 'j_upload_btn_'+id;
            img.id = 'j_upload_img_'+id;
            button = $(btn);
            image = $(img);
            // TODO 修改以下参数
            Uploader1 = new plupload.Uploader({
                runtimes : 'gears,html5,flash,silverlight,browserplus',
                browse_button : 'j_upload_btn_'+id,
                // container: 'js_add_wrap',
                max_file_size : '10mb',
                url : 'plupload/examples/upload.php',
                resize : {width : 320, height : 240, quality : 90},
                flash_swf_url : 'plupload/js/plupload.flash.swf',
                silverlight_xap_url : 'plupload/js/plupload.silverlight.xap',
                multi_selection:false,
                filters : [
                    {title : "Image files", extensions : "jpg,gif,png"},
                    {title : "Zip files", extensions : "zip"}
                ]
            });
            // 初始化事件
            Uploader1.bind('Init', function(up, params) {
            });
            // 初始化
            Uploader1.init();
            // 添加图片事件
            Uploader1.bind('FilesAdded', function(up, files) {
                image.attr('src','img/loading.gif');
                Uploader1.start();
            });
            // 上传进程事件
            Uploader1.bind('UploadProgress', function(up, file) {
            });
            // 上传完成
            Uploader1.bind('FileUploaded', function(up, file,msg) {
                var response = eval('(' + (msg.response.replace(/\\/g,'/')) + ')');
                console.log('上传成功',image,msg);
                image.attr('src','plupload/examples/'+response.result);
            });
        },
        stop:function(){
            if(Uploader1){
                Uploader1.stop();
            }
        }
     };
  })();
  // 正在操作的id
  var currentId;
  var getId = function(trigger){
    var tr = trigger.parents('[item-id]');
    return tr.attr('item-id');
  };

  // 添加客服号
  dom.wrap.on('click','.mod-control .btn',function(){
             if(!DialogAdd){
                // confirm框
                DialogAdd = new __Dialog__(AddHtml,{
                   scroll:false,
                   onConfirm:function(){
                      var self = this;
                      var item = DialogControler.getData(self.dom.ids);

                      var sParam = JSON.stringify(item);
                      // $.ajax({
                      //   type: "POST",
                      //   url: "CustomServiceEx.aspx/AddKefu",
                      //   data: {
                      //     post_data: sParam
                      //   },
                      //   contentType: "application/json; charset=utf-8",
                      //   dataType: "json",
                      //   success: function(msg) {
                      //     self.hide();
                      //     // id应该是后端返回
                      //     item.kf_id = (new Date()).getTime();
                      //     TableControler.add(item);
                      //   },
                      //   error: function(e) {
                      //     alert("Something Wrong.");
                      //   }
                      // });

                      // TODO 提交到后端后 添加
                      setTimeout(function(){
                         self.hide();
                         // 添加到表格
                         // TableControler.add({
                         //       kf_id:(new Date()).getTime(),
                         //       kf_nick:'小月'+(new Date()).getTime(),
                         //       kf_account:'diachang',
                         //       kf_headimgurl:'img/avatar-small.png',
                         //       kf_password:'123456'
                         // });
                         // id应该是后端返回
                         item.kf_id = (new Date()).getTime();
                         TableControler.add(item);
                      }, 0);
                   },
                   onCancel:function(){

                   },
                   onClose:function(){

                   },
                   onHide:function(){
                     UploaderControler.stop();
                   },
                   onShow:function(){
                    var self = this;
                    var dom = self.dom.ids;
                     UploaderControler.init(dom.kf_uploadbtn,dom.kf_headimgurl);
                   },
                   afterRender:function(self){


                   }
                });
             }

             DialogAdd.show();
  });
  // 修改客服号
  dom.wrap.on('click','.mod-list .edit a',function(){
    var trigger = $(this);
    // 获取id
    currentId = getId(trigger);
    if(!DialogEdit){
       // confirm框
       DialogEdit = new __Dialog__(EditHtml,{
          scroll:false,
          onConfirm:function(){
             var self = this;
             // TODO 提交到后端后 编辑
             setTimeout(function(){
                self.hide();
                var item = DialogControler.getData(self.dom.ids);
                // 添加到表格
                TableControler.edit(item);
             }, 0);
          },
          onCancel:function(){

          },
          onClose:function(){

          },
          onHide:function(){
            UploaderControler.stop();
          },
          afterRender:function(){

          },
          onShow:function(){
            var self = this;
            var item = TableControler.getData(currentId);
            DialogControler.setData(this.dom.ids,item);
            var dom = self.dom.ids;
             UploaderControler.init(dom.kf_uploadbtn,dom.kf_headimgurl);
          }
       });
    }
    DialogEdit.show();
  });
  // 删除客服号
  dom.wrap.on('click','.mod-list .delete a',function(){
    var trigger = $(this);
    // 获取id
    currentId = getId(trigger);
    if(!DialogDel){
       // confirm框
       DialogDel = new __Dialog__(DelHtml,{
          scroll:false,
          onConfirm:function(){
             var self = this;
             // TODO 提交到后端后 删除
             setTimeout(function(){
                self.hide();
                TableControler.remove(currentId);
             }, 0);
          },
          onCancel:function(){

          },
          onClose:function(){

          },
          onHide:function(){

          },
          afterRender:function(self){
          }
       });
    }
    DialogDel.show();
  });

})();