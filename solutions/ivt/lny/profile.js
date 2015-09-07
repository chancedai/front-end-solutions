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

    var openid = getParam('openid');
    var nickname = getParam('nickname');
	var dom = getNodes('#js_page_profile');
// 	//检查今天的签到状态
// 	var checkSignState = function(openid,dom){
// 	    $.ajax({
//             type: "POST",
//             url: "sign.aspx/IVT_WX_checkSignStateByOpenid",
//             data: '{"openid" : "'+ openid+'"}',
//             contentType: "application/json; charset=utf-8",
//             dataType: "json",
//             success: function(data, status) {
//                 if(status=='success'){
//                     var state = eval(data.d);
//                     if(state == 1){
//                         var signBtn = document.getElementById('sign-in-btn');
// 		                signBtn.disabled = true;
// 		                signBtn.style.backgroundColor = "#C0C0C0";
// 		                signBtn.style.border = "#C0C0C0";
//
// 			            dom.prompt.html(['<p>亲，您今天已签到。</p>'].join(''));
//                     }
//                     else{
//                     }
// 	            }
//
//             },
//             error: function(e) {
//                 alert("Something Wrong.");
//             }
//         });
// 	};

	var submit = function(openid, nickname, dom){
	    $.ajax({
            type: "POST",
            url: "UserCenter.aspx/IVT_WX_SubmitProfile",
            data: '{"openid" : "'+ openid+'", "nickname" : "'+ nickname+'"}',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(data, status) {
                if(status=='success'){
                    var result = eval(data.d);
                    if(result > 0){
                        alert("完善资料积分添加");
                    }
	            }
            },
            error: function(e) {
                alert("Something Wrong.");
            }
        });
	};

/*	checkSignState(openid, dom);*/
	//点击签到按钮
	dom.wrap.on('click','.ft .btn', function(e) {
        var frm = dom.profileForm[0];
        var name = frm.name.value;
        var nick = frm.nick.value;
		submit(openid, nickname, dom);
	});


})();