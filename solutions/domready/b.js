console.log('b.js��ʼִ��');
console.time('bjs');
var alertt = function(txt){
	txt = txt||'';
	console.log('b.js��domready��ʼִ��'+txt);
	console.timeEnd('bjs');
};
if(document.readyState === "complete"){
	alertt();
}else if(document.readyState === "interactive"){
	alertt('(��ʵ��interactive)');
}else{
	document.addEventListener("DOMContentLoaded", function() {
		alertt();
	});
}
