var ScrollPage = (function(){
	var noop = function(){};
	// 滚动多少次显示分页
	var times;
	// 每次加载多少个
	var smallPageNum;
	// 分页时每页多少个
	var pageNum;
	// 现在每几页
	var smallPageIndex = 1;
	// 总个数
	var totalNum = 0;
	var smallPageCallback = noop;
	var pageCallback = noop;
	var hasPage = false;
	return {
		init:function(opt){
			times = opt.times||3;
			smallPageNum = opt.smallPageNum||20;
			pageNum = times*smallPageNum;
			smallPageCallback = opt.smallPageCallback||noop;
			pageCallback = opt.pageCallback||noop;
		}
		scroll:function(){
			if(hasPage){
				return;
			}
			var self = this;
			smallPageNum(self,smallPageIndex);
			times++;
			if((times-1)===3){
				pageCallback(self,pageNum)
			}else{
				smallPageIndex++;
			}
		},
		setSmallPage = function(index){
			smallPageIndex = index;
		}
	};
})();
ScrollPage.init(3,20,function(){

},function(){

});
getData(function(msg){

});