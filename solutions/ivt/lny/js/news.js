;
(function() {
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

	var getNewsId = (function(){
		var id = '';
		return function(){
			if(!id){
				var sArr = location.href.split('/');
				var name = sArr[sArr.length-1];
				id = name.split('.')[0];
			}
			return id;
		};
	})();

	var getParam = function(key) {
	    var params = location.search;
	    if (params) {
	        var arr = params.substr(1).split('&');
	        for (var i = 0; i < arr.length; i++) {
	            data = arr[i].split('=');
	            if (data[0] == key) {
	                return data[1];
	            }
	        }
	    }
	};

	var id = getNewsId();
	var dom = getNodes($('#js_page_news'));
	var getNewsDetail = function(id,dom){
		function changeDateFormat(jsondate) {
		    jsondate = jsondate.replace("/Date(", "").replace(")/", "");
		    if (jsondate.indexOf("+") > 0) {
		        jsondate = jsondate.substring(0, jsondate.indexOf("+"));
		    }
		    else if (jsondate.indexOf("-") > 0) {
		         jsondate = jsondate.substring(0, jsondate.indexOf("-"));
		    }

		    var date = new Date(parseInt(jsondate, 10));
		    var month = date.getMonth() + 1 < 10 ? "0" + (date.getMonth() + 1) : date.getMonth() + 1;
		    var currentDate = date.getDate() < 10 ? "0" + date.getDate() : date.getDate();
		    return date.getFullYear() + "-" + month + "-" + currentDate;
		 }
		$.ajax({
	      url:"http://1000moons.com/information/GetNewsDetail.ashx?action=GetNewsDetail&ID="+id+"&time="+new Date().getTime(),
	      type:"GET",
	      before:function(){
	           // dom.post.empty().append('')
	      },
	      success:function(data,status){
	           if(status=='success'){
	              if(data!='暂无数据显示'){
	                 dom.post.empty();
	                 var newsdetail=$.parseJSON(data);//反序列化json数据
	                for (var i = 0, len = newsdetail.length; i < len; i++) {
	                	var item =newsdetail[i];
	                	var vReleaseDate=changeDateFormat(item.ReleaseDate);//获取被处理后的日期
	                	// 面包屑
	                	dom.breadcrumb.html([
							'您现在所在的位置：&nbsp;&nbsp;',
							'<a href="../index.html">千月首页</a>',
							'&nbsp;&nbsp;&gt;&nbsp;&nbsp;',
							'<a href="index.html">千月资讯</a>',
							'&nbsp;&nbsp;&gt;&nbsp;&nbsp;',
							'<a href="'+item.TypeUrl+'">'+item.TypeName+'</a>',
							'&nbsp;&nbsp;&gt;&nbsp;&nbsp;',
							'<span>'+item.Title+'</span>'
						].join(''));
	                	// 文章内容 标题 关键字 责任编辑 浏览量 评论量 来源
	                	var postHtml = [
	                		'<!-- 文章标题 -->',
	                		'<h2>'+item.Title+'</h2>',
	                		'<!-- / 文章标题 -->',
	                		'<!-- 文章信息 -->',
	                		'<div class="post-info">',
	                		    '<span class="post-time">'+vReleaseDate+'</span>',
	                		    '<span class="post-author">来源'+item.Origin+'</span>',
	                		    '<span class="post-comments">评论量：0</span>',
	                		    '<span class="post-views">浏览量：'+item.BrowseCount+'</span>',
	                		    '<p class="post-keywords">关键字：'+item.KeyWords+'</p>',
	                		'</div>',
	                		'<!-- / 文章信息 -->',
	                		'<!-- 文章内容 -->',
	                		'<div class="post-content">',
	                		item.Content,
	                		'</div>',
	                		'<!-- / 文章内容 -->'
	                	].join('');
	                	dom.post.append(postHtml);
	                }
	              }
	           }
	      }
	    });
	};
	// 测试
	id = '687';
	getNewsDetail(id,dom);

})();