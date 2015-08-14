console.log('b.js开始执行');
console.time('bjs');
var alertt = function(txt){
	txt = txt||'';
	console.log('b.js的domready开始执行'+txt);
	console.timeEnd('bjs');
};
if(document.readyState === "complete"){
	alertt();
}else if(document.readyState === "interactive"){
	alertt('(其实是interactive)');
}else{
	document.addEventListener("DOMContentLoaded", function() {
		alertt();
	});
}
