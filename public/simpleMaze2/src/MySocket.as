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

	public class MySocket extends Sprite{
		public var socket:Socket;
		public var myParent:GameStage;
		public var port : int = 23456;
		public function MySocket(_p : GameStage = null){
			myParent = _p;
			
/*			myParent.networkUse = false;
			myParent.initialize();
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
			if (!myParent.startFlag && limitTimes > 3) {
				myParent.networkUse = false;
				myParent.initialize();
				return;
			}
			socket.connect("59.78.44.40", port);
			//setTimeout(checkConnection, 50);
			//trace("drop!?!?!?!?!?!?!");
		}
		public function onConnect(e:Event):void{
			if (!myParent.startFlag && socket.connected) {
				myParent.networkUse = true;
			}
			//trace("con!?!?!?!?!?!?! " + String(socket.connected));
			setTimeout(checkConnection, 99);
		}
		public static var ac : int = 0;
		public static var drop : int = 1;
		
		public function sendWinMessage(_id : int, _x : int, _y : int, _name : String, _ig : Boolean, _iz : Boolean, _room : int, _al : Boolean, _seed : int) : void
		{
			//return;			
			var o : Object = new Object();
			o.type = "win";
			o.id = _id;
			o.x = _x;
			o.y = _y;
			o.ghost = _ig;
			o.zombie = _iz;
			o.name = _name;
			o.room = _room;
			o.alive = _al;
			o.seed = _seed;
			
			if (socket.connected) {
				socket.writeUTFBytes(JSON.stringify(o));
				socket.flush();
			} else {
				drop += 1;
			}
		}
		public function sendMessage(_id : int, _x : int, _y : int, _name : String, _ig : Boolean, _iz : Boolean, _room : int, _al : Boolean, _seed : int) : void
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
			
			//trace(socket.connected);
			trace("!!send   " + JSON.stringify(o));
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
		public function sendGhostMessage(_id : int, _cd : int, _trap : int) : void
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
		
		public function dropMessage(_id : int, _x : int, _y : int, _name : String, _ig : Boolean, _iz : Boolean, _room : int, _al : Boolean, _seed : int) : void
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
			
			//trace("收到的数据："+socket.bytesAvailable+"b/s");
			//循环读取收到的数据，以字符码显示
			var st : String = "";
			//trace("1" + e.toString());
			st = last;
			while(socket.bytesAvailable) {
				st += socket.readUTFBytes(socket.bytesAvailable);
			}
			//trace("work: " + st);
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
				var id : int = a.id;
				var room : int = a.room;
				var ghost : Boolean = a.ghost;
				var zombie : Boolean = a.zombie;
				var alive : Boolean = a.alive;
				var name : String = a.name;
				var seed : int = a.seed;
				var myx : int = a.x;
				var myy : int = a.y;
				//trace("work: " + s);
				if (id < 0) {
					if (myParent.seed == -1) {
						myParent.playerId = -id;
						myParent.seed = seed;
												
						myParent.networkUse = true;
						myParent.initialize(myx, myy);
						//trace("get " + String(-id) + " and seed " + String(seed));
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
							flag = true;
							break;
						}
					}
					if (!flag)
						players.push(new PlayerInfo(id, myx, myy, name, ghost, zombie, alive, room, seed));
				} else if (type == "dead") {
					if (id == myParent.playerId) {
						myParent.addDeadMessage();
					} else {
						myParent.deadGrid(myx, myy);
						myParent.deadUser(id, name);
					}
					//myParent.changeFloor
				} else if (type == "drop") {
					var len : int = players.length;
					for (var i : int = 0; i < len; i++) {
						if (players[i].id == id) {
							myParent.removePlayer(players[i]);
							players[i] = players[len - 1];
							players.pop();
							break;
						}
					}
				} else if (type == "trapped") {
					myParent.actTrap(myx, myy);
				}
			}
		}
		public var players : Vector.<PlayerInfo> = new Vector.<PlayerInfo>;
	}
	
}