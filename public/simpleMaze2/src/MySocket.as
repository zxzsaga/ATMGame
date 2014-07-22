package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import starling.events.KeyboardEvent;
	import starling.text.TextField;

	public class MySocket extends Sprite{
		public var socket:Socket;
		public var director:Director;
		public var port : int = 23456;
		public var myping : int = 0;
		public function MySocket(_p : Director = null) : void{
			director = _p;
			
			/*director.networkUse = false;
			director.createRoom();
			//director.gameStart();
			return;*/
			
			socket=new Socket();
			//Security.loadPolicyFile("http://localhost/crossdomain.xml");
			socket.addEventListener(Event.CONNECT, onConnect);//注册侦听函数
			socket.addEventListener(ProgressEvent.SOCKET_DATA,onSocketData);//侦听接收到数据执行的函数
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			checkConnection();
			//trace("!");
		}
		public function onError(e:Event):void{
			trace("fail connect");
			checkConnection();
			return;
		}
		public var flag : Boolean = false;
		public var limitTimes : int = 0; 
		public function checkConnection() : void
		{
			if (socket.connected) {
				//setTimeout(checkConnection, 50);
				return;
			}
			limitTimes = limitTimes + 1;
			/*if (!director.startFlag && limitTimes > 3) {
				director.networkUse = false;
				director.initialize();
				return;
			}*/
			//socket.connect("192.168.1.104", port);
			socket.connect("218.244.133.160", port);
			trace("hi");
			//setTimeout(checkConnection, 50);
			//trace("drop!?!?!?!?!?!?!");
		}
		public function onConnect(e:Event):void{
			director.networkUse = true;
			/*if (!director.startFlag && socket.connected) {
				director.networkUse = true;
			}*/
			trace("con!?!?!?!?!?!?! " + String(socket.connected));
			director.readyPing();
			director.mySocket.sendJoinMessage(director.roomName.text, director.userName);
			//setTimeout(checkConnection, 99);
		}
		public static var ac : int = 0;
		public static var drop : int = 1;
		
		public function sendWinMessage(_id : int, _x : int, _y : int, _name : String, _ig : Boolean, _iz : Boolean, _room : int, _al : Boolean, _seed : int, _ping : int) : void
		{
			//return;			
			var o : Object = new Object();
			o.type = "win";
			o.name = "human";
			o.id = _id;
			o.room = _room;
			/*o.id = _id;
			o.x = _x;
			o.y = _y;
			o.ghost = _ig;
			o.zombie = _iz;
			o.room = _room;
			o.alive = _al;
			o.seed = _seed;*/
			
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			} else {
				drop += 1;
			}
		}
		public function sendMessage(_id : int, _x : int, _y : int, _name : String, _ig : Boolean, _iz : Boolean, _room : int, _al : Boolean, _seed : int, _ping : int) : void
		{
			//return;			
			var o : Object = new Object();
			o.type = "pos";
			o.id = _id;
			o.x = _x;
			o.y = _y;
			o.ghost = _ig;
			o.zombie = _iz;
			o.name = _name;
			o.room = _room;
			o.alive = _al;
			o.seed = _seed;
			o.ping = _ping;
			
			//trace(socket.connected);
			//trace("!!send   " + JSON.stringify(o));
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
				ac = ac + 1;
				//trace(JSON.stringify(o));
			} else {
				drop += 1;
			}
		//	trace(ac / Number(drop + ac));
		}
		/*public function sendGhostMessage(_id : int, _cd : int, _trap : int) : void
		{
			var o : Object = new Object();
			o.type = "monster";
			o.id = _id;
			o.convertCd = _cd;
			o.trapremain = _trap;
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			}
		}*/
		public function sendStartMessage() : void
		{
			var o : Object = new Object();
			o.type = "room";
			o.info = "start";
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			}
		}
		public function sendJoinMessage(_r : String, _name : String) : void
		{
			var o : Object = new Object();
			o.type = "room";
			o.info = "join";
			o.room = _r;
			o.name = _name;
			//o.type = "yes";
			//o.type = "no";
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			}
		}
		public function sendRoomMessage(_id : int, _name : String, _ig : Boolean, _ping : int, _ih : Boolean, _room : int, _text : String) : void
		{
			var o : Object = new Object();
			o.type = "room";
			o.info = "status";
			o.id = _id;
			o.name = _name;
			o.ghost = _ig;
			o.ping = _ping;
			o.host = _ih;
			o.room = _room;
			o.text = _text;
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			}
		}
		public function sendGameChatMessage(_c : String, _name : String) : void
		{
			var o : Object = new Object();
			o.type = "gameChat";
			o.name = _name;
			o.content = _c;
			trace("fale");
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			}
		}
		public function sendChatMessage(_c : String, _name : String) : void
		{
			var o : Object = new Object();
			o.type = "chat";
			o.name = _name;
			o.content = _c;
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			}
		}
		public function sendQuitMessage(_id : int, _name : String, _ig : Boolean, _ping : int, _ih : Boolean, _room : int) : void
		{
			var o : Object = new Object();
			o.type = "room";
			o.info = "quit";
			o.id = _id;
			o.name = _name;
			o.ghost = _ig;
			o.ping = _ping;
			o.host = _ih;
			o.room = _room;
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			}
		}
		public function sendTrapMessage(_id : int, _x : int, _y : int) : void
		{
			var o : Object = new Object();
			o.type = "trap";
			o.id = _id;
			o.x = _x;
			o.y = _y;
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			}
		}
		
		public function dropMessage(_id : int, _x : int, _y : int, _name : String, _ig : Boolean, _iz : Boolean, _room : int, _al : Boolean, _seed : int, _ping : int) : void
		{
			//return;
			var o : Object = new Object();
			o.type = "drop";
			o.id = _id;
			o.x = _x;
			o.y = _y;
			o.ghost = _ig;
			o.zombie = _iz;
			o.name = _name;
			o.room = _room;
			o.alive = _al;
			o.seed = _seed;
			o.ping = _ping;
			//trace(socket.connected);
			//trace("!!send   " + JSON.stringify(o));
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
				ac = ac + 1;
				//trace(JSON.stringify(o));
			} else {
				drop += 1;
			}
			//	trace(ac / Number(drop + ac));
		}
		public var last : String = "";
		public function onSocketData(e:ProgressEvent) : void {
			if (director.gameState == 1 && director.mainStage != null && director.mainStage.startFlag) {
				director.mainStage.lastUpdate = director.mainStage.frame;
			}
			//trace("收到的数据："+socket.bytesAvailable+"b/s");
			//循环读取收到的数据，以字符码显示
			var st : String = "";
			//trace("1" + e.toString());
			st = last;
			while(socket.bytesAvailable) {
				st += socket.readUTFBytes(socket.bytesAvailable);
			}
			trace("work: " + st);
			//trace("!!!json   " + st);
			while (st.length) {
				var s : String = "";
				var len : int = st.length;
				for (var i : int = 0; i < len; i++)
					if (st.charAt(i) == "}") {
						s = st.substring(0, i + 1);
						st = st.substring(i + 1, len);
						break;
					}
				if (s == "") {
					last = "";
					break;
				}
				while (s.length && s.charAt(0) == " ") s = s.substr(1);
				if (s.charAt(0) != "{") {
					continue;
				}
				
				var a : Object = JSON.parse(s);
				
				var type : String = a.type;
				if (type == "failed") {
					if (director.failedInfo == null) {
						director.failedInfo = new TextField(202, 151, "FAILED JOIN!", "Arial", 33);
						director.failedInfo.x = 850;
						director.failedInfo.y = 198;
						director.addChild(director.failedInfo);
					}
				} else if (type == "success") {
					//trace("!!!!!");
					if (director.gameState != 0) {
						director.gameState = 0;
						director.roomMenu = new RoomMenu();
						director.roomMenu.ping = director.calcPing();
						director.roomMenu.initialize(director, director.roomName.text);
						director.removeChildren();
						director.removeEventListeners();
						director.addChild(director.roomMenu);
					}
				} else if (type == "chat") {
					var name : String = a.name;
					var content : String = a.content;
					director.roomMenu.getChat(content, name);
				} else if (type == "gameChat") {
					trace("tes " + content);
					var name : String = a.name;
					var content : String = a.content;
					director.mainStage.getChat(content, name);
				} else if (type == "win") {
					var name : String = a.name;
					director.mainStage.gameOver(name);
				} else if (type == "drop") {
					var len : int = players.length;
					var id : int = a.id;
					for (var i : int = 0; i < len; i++) {
						if (players[i].id == id) {
							director.mainStage.removePlayer(players[i]);
							players[i] = players[len - 1];
							players.pop();
							break;
						}
					}
				} else if (type == "host") {
					var id : int = a.id;
					//trace("~~" + id + " " + director.roomMenu.myId);
					director.roomMenu.updateMine(director.roomMenu.myId, director.roomMenu.myName, director.roomMenu.isGhost, director.roomMenu.ping, director.roomMenu.myId == id, director.roomMenu.room,  director.roomMenu.playerTypeName);
					director.roomMenu.addUser(director.roomMenu.myId, director.roomMenu.myName, director.roomMenu.isGhost, director.roomMenu.ping, director.roomMenu.myId == id, director.roomMenu.room, director.roomMenu.playerTypeName);
				} else if (type == "room") {
					var id : int = a.id;
					var info : String = a.info;
					var ping : int = a.ping;
					var host : Boolean = a.host;
					var name : String = a.name;
					var ghost : Boolean = a.ghost;
					var text : String = a.text;
					if (info == "status") {
						director.gameState = 0;
						if (id < 0) {
							id = -id;
							director.roomMenu.updateMine(id, name, ghost, ping, host, room, text);
							director.roomMenu.addUser(id, name, ghost, ping, host, room, text);
						} else 
							director.roomMenu.addUser(id, name, ghost, ping, host, room, text);
					} else if (info == "quit") {
						if (director.gameState == 1) {
							var len : int = players.length;
							for (var i : int = 0; i < len; i++) {
								if (players[i].id == id) {
									director.mainStage.removePlayer(players[i]);
									players[i] = players[len - 1];
									players.pop();
									break;
								}
							}
						} else {
							director.roomMenu.removeUser(id);
						}
						//if director.mainStage.removePlayer(
					} else if (info == "start") {
						director.gameState = 1;
						director.gameStart(ghost, seed);
					}
				} else {
					var id : int = a.id;
					var room : int = a.room;
					var ghost : Boolean = a.ghost;
					var zombie : Boolean = a.zombie;
					var alive : Boolean = a.alive;
					var name : String = a.name;
					var seed : int = a.seed;
					var myx : int = a.x;
					var myy : int = a.y;
					var ping : int = a.ping;
					//trace("work: " + s);
					if (type == "pos" && id < 0) {
						//if (director.mainStage.seed == -1) {
							//director.networkUse = true;
							//director.mainStage.initialize(myx, myy);
							//trace("get " + String(-id) + " and seed " + String(seed));
						//}
						if (!director.mainStage.startFlag) {
							director.mainStage.playerId = -id;
							director.mainStage.seed = seed;
							director.mainStage.inRoom = room;
							director.mainStage.initialize();
						} else {
							director.mainStage.refreshPing();
						}
					} else if (type == "pos") {
						var flag : Boolean = false;
						for (var i : int = 0; i < players.length; i++) {
							if (players[i].id == id) {
								players[i].x = myx;
								players[i].y = myy;
								players[i].isGhost = ghost;
								players[i].isZombie = zombie;
								players[i].name = name;
								players[i].alive = alive;
								players[i].room = room;
								players[i].ping = ping;
								players[i].seed = seed;
								flag = true;
								break;
							}
						}
						if (!flag)
							players.push(new PlayerInfo(id, myx, myy, name, ghost, zombie, alive, room, seed, ping));
					} else if (type == "dead") {
						if (id == director.mainStage.playerId) {
							director.mainStage.addDeadMessage();
						} else {
							director.mainStage.deadGrid(myx, myy);
							director.mainStage.deadUser(id, name);
						}
						//director.changeFloor
					} else if (type == "trapped") {
						director.mainStage.actTrap(myx, myy);
					} else if (type == "trap") {
						director.mainStage.trapSpace.addTrap(myx, myy);
					}
				}
			}
		}
		public var players : Vector.<PlayerInfo> = new Vector.<PlayerInfo>;
	}
	
}