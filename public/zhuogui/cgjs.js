// JavaScript Document
var socket = io.connect('http://localhost:8002');
var uname;
var gamestat;
var playerstat = {};

/*
socket.on('catchghost', function (data) {
	console.log(data);
	socket.emit('my other event', { my: 'data' });
});
*/

function cginit()
{
	uname = getCookie('uname');
	gamestat = ""
	$(".Mainblock").hide();
	$("#Enterroom").show();
	playerstat.myseat = 0;
	/*
	if (uname!="")
		socket.emit('cginfo',{
			'username':uname
		});*/	
}

function preroominit(){
	for (var i=0;i<10;i++){
		var style1,style2,style3;
		if (i<5){
			style1="top:0px;left:"+(244*i)+"px";
			style2="top:20px;left:"+(244*i)+"px";
			style3="top:0px;left:"+(70+244*i)+"px";
		}
		else{
			style1="top:264px;left:"+(244*(i-5))+"px";
			style2="top:284px;left:"+(244*(i-5))+"px";
			style3="top:264px;left:"+(70+244*(i-5))+"px";
		}
		$("#playercharcont").append('<div id="playername'+i+'" class="playername" style="position:absolute;'+style1+'"></div>');
		$("#playercharcont").append('<div id="playerstat'+i+'" class="playerstat" style="position:absolute;'+style3+'">Noplayer</div>');
		$("#playercharcont").append('<img id="playeravatar'+i+'" class="playeravatar" style="position:absolute;'+style2+'" src="img/character/avatar-L/20.png" />');
	}
	for (var i=0;i<20;i++){
		var num,style;
		if (i<10){
			num="0"+i;
			style="top:0px;left:"+(300+46*i)+"px";
		}
		else{
			num=""+i;
			style="top:142px;left:"+(300+46*(i-10))+"px";
		}
		$("#selcharcont").append('<img id="selchar_small_shadow'+num+'" class="selcharsmallshadow" style="position:absolute;'+style+';z-index:3;" src="img/character/select_small/shadow.png" />');
		$("#selcharcont").append('<img id="selchar_small'+num+'" class="selcharsmall" style="position:absolute;'+style+'" src="img/character/select_small/'+num+'.png" />');
		$("#selchar_small"+num).mousemove(function(n){
			return function () {
				$("#select_large").attr("src","img/character/select_large/"+n+".png");
			};
		}(num));
		$("#selchar_small"+num).click(function(n){
			return function () {
				choosechar(n)
				//$("#playeravatar1").attr("src","img/character/avatar-L/"+n+".png");//test
				$("#selcharcont").hide();
			};
		}(num));
	}
	$("#selchar_rand").mousemove(function(){
		$("#select_large").attr("src",null);
	});
	$("#selchar_rand").click(function(){
		choosechar(20)
		$("#selcharcont").hide();
	});
	$(".selcharsmallshadow").hide();
	$("#selcharcont").hide();
}

function enteroom(){
	uname = $("#username").val();
	addCookie('uname',uname,24);
	preroominit();
	$(".Mainblock").hide();
	$("#Preroom").show();
	socket.emit('enteroom',{
		'username':$("#username").val(),//用户名
		'roomnum':$("#roomnum").val()//房间编号
	});//建立或加入房间
}

socket.on('enteroom', function (data){
	console.log(data);
	for (var i=0;i<data.playernum;i++){//data.playernum 房间人数
		$("#playername"+data.player[i].seat).html(data.player[i].name);//data.player 用户信息 .name 用户名 .seat 座位编号(0-9)
		$("#playerstat"+data.player[i].seat).html(data.player[i].stat);//.seat 用户状态(房主/准备/未准备)
		$("#playeravatar"+data.player[i].seat).attr("src","img/character/avatar-L/"+data.player[i].cha+".png");//.cha 用户角色编号(默认为20)
		if (data.player[i].cha<20)
			$("#selchar_small_shadow"+data.player[i].cha).show();
	}
	playerstat.myseat = data.myseat;//data.myseat 当前用户座位编号
	playerstat.mystat = $("#playerstat"+playerstat.myseat).html();
	$("#playeravatar"+playerstat.myseat).click(function(){
		$("#selcharcont").show();
	});
});//玩家进入房间时，返回房间信息

socket.on('roomplayerenter', function (data){
	console.log(data);
	$("#playername"+data.seat).html(data.name);//data.name 进入房间用户的用户名 data.seat 进入房间的用户的座位编号
	$("#playerstat"+data.seat).html("未准备");
	/*
	$("#playeravatar"+data.seat).attr("src","img/character/avatar-L/"+data.cha+".png");
	if (data.cha<20)
		$("#selchar_small_shadow"+data.cha).show();
	*/
});//玩家进入房间时，向其他玩家发送该玩家信息

socket.on('roomplayerleave', function (data){
	console.log(data);
	$("#playername"+data.seat).html("");//data.seat 离开房间的用户的座位编号
	$("#playerstat"+data.seat).html("Noplayer");
	if (data.cha<20)//data.cha 离开房间的用户角色编号(默认为20)
		$("#selchar_small_shadow"+data.cha).hide();
});//玩家离开房间时，向其他玩家发送该玩家信息

function changechar(){
	$("#selcharcont").show();
}

function changechar_return(){
	$("#selcharcont").hide();
}

function choosechar(charid){
	socket.emit('choosechar',{
		'username':uname,
		'charid':charid//所选择的角色编号
	});//玩家选择角色
	$("#playeravatar"+playerstat.myseat).attr("src","img/character/avatar-L/"+charid+".png");
}

socket.on('choosechar', function (data){
	console.log(data);
	$("#playeravatar"+data.seat).attr("src","img/character/avatar-L/"+data.cha+".png");//data.seat 选择角色的用户座位编号 data.cha 用户新选择的角色编号
	if (data.cha<20)
		$("#selchar_small_shadow"+data.cha).show();
	if (data.lstcha<20)//data.lstcha 用户之前选择的角色编号
		$("#selchar_small_shadow"+data.lstcha).hide();
});//玩家选择角色时，向其他玩家发送该信息

function prepare(){
	if ($("#playerstat"+playerstat.myseat).html() == "host"){
		alert("!!!");
		return;
	}
	socket.emit('prepare',{
		'username':uname,
	});//玩家更改准备状态
	if ($("#playerstat"+playerstat.myseat).html() == "未准备")
		$("#playerstat"+data.seat).html("已准备");
	else
		$("#playerstat"+data.seat).html("未准备");
}

socket.on('prepare', function (data){
	console.log(data);
	$("#playerstat"+data.seat).html(data.stat);//data.seat 更改状态的用户座位编号 data.statr 用户当前状态
});//玩家更改状态时，向其他玩家发送该信息

function gamestart(){
	socket.emit('gamestart',{
		'username':uname
	});
}

socket.on('gamestart', function (data){
	console.log(data);
	alert("暂时就做到这里")
});//游戏开始时，向所有玩家发送该信息

/*
socket.on('cginfo', function (data){
	console.log(data);
	switch (data.stat){
		case 'prepare':{
			switch(data.action){
				case 'selchar':{
					$(".").toggle();
				}
			}
		}
		break;
	}
});*/

function addCookie(name,value,expiresHours){
	var cookieString=name+"="+escape(value);  
	if(expiresHours>0){ 
		var date=new Date();
		date.setTime(date.getTime()+expiresHours*3600*1000); 
		cookieString=cookieString+"; expires="+date.toGMTString(); 
	} 
	document.cookie=cookieString; 
}

function getCookie(name){ 
	var strCookie=document.cookie; 
	var arrCookie=strCookie.split("; "); 
	for(var i=0;i<arrCookie.length;i++){ 
		var arr=arrCookie[i].split("="); 
		if(arr[0]==name)
			return arr[1]; 
	} 
	return ""; 
}

function deleteCookie(name){ 
	var date=new Date(); 
	date.setTime(date.getTime()-10000); 
	document.cookie=name+"=v; expires="+date.toGMTString();
} 