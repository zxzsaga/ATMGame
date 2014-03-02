package
{
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class RoomMenu extends Sprite
	{
		public function RoomMenu()
		{
			super();
		}
		public function initialize(_d : Director, _name : String) : void
		{
			director = _d;
			roomName = _name;
			
			roomInfo = new TextField(120, 60, "Room " + _name, "Arial", 33);
			//roomInfo.touchable = true;
			roomInfo.x = 100;
			roomInfo.y = 10;
			roomInfo.hAlign = HAlign.CENTER;  // 横向对齐
			roomInfo.vAlign = VAlign.CENTER; // 纵向对其
			roomInfo.border = true;
			addChild(roomInfo);
			
			exitButton = new TextField(120, 51, "Exit", "Arial", 33);
			exitButton.touchable = true;
			exitButton.x = 1188;
			exitButton.y = 555;
			exitButton.hAlign = HAlign.CENTER;  // 横向对齐
			exitButton.vAlign = VAlign.CENTER; // 纵向对其
			exitButton.border = false;
			exitButton.addEventListener(TouchEvent.TOUCH, onExit);
			addChild(exitButton);
			
			ghostButton = new TextField(120, 51, "Ghost", "Arial", 33);
			ghostButton.touchable = true;
			ghostButton.color = Color.RED;
			ghostButton.x = 1088;
			ghostButton.y = 155;
			ghostButton.hAlign = HAlign.CENTER;  // 横向对齐
			ghostButton.vAlign = VAlign.CENTER; // 纵向对其
			ghostButton.border = true;
			ghostButton.addEventListener(TouchEvent.TOUCH, onGhost);
			addChild(ghostButton);
			
			humanButton = new TextField(120, 51, "Human", "Arial", 33);
			humanButton.color = Color.WHITE;
			humanButton.touchable = true;
			humanButton.x = 1088;
			humanButton.y = 222;
			humanButton.hAlign = HAlign.CENTER;  // 横向对齐
			humanButton.vAlign = VAlign.CENTER; // 纵向对其
			humanButton.border = true;
			humanButton.addEventListener(TouchEvent.TOUCH, onHuman);
			addChild(humanButton);
			
			userId = new Vector.<int>();
			textList = new Vector.<TextField>();
			//nextY = 30;
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandle);
		}
		
		public function fixLength(a : String, _len : int) : String
		{
			if (a.length < _len) {
				var s : String = "";
				for (var l : int = _len - a.length; l >= 0; l--) {
					s += " ";
				}
				return a + s; 
			} else return a;
		}
		public function updateMine(_id : int, _name : String, _ig : Boolean, _ping : int, _ih : Boolean, _room : int) : void
		{
			myId = _id;
			myName = _name;
			isGhost = _ig;
			ping = _ping;
			isHost = _ih;
			room = _room;
			//trace("what " + isHost + "  " + !hostFlag);
			if (isHost && !hostFlag) {
				hostButton = new TextField(120, 51, "Start!", "Arial", 33);
				hostButton.touchable = true;
				hostButton.x = 1188;
				hostButton.y = 500;
				hostButton.hAlign = HAlign.CENTER;  // 横向对齐
				hostButton.vAlign = VAlign.CENTER; // 纵向对其
				hostButton.border = false;
				hostButton.addEventListener(TouchEvent.TOUCH, onStart);
				addChild(hostButton);
			}
		}
		public function addUser(_id : int, _name : String, _ig : Boolean, _ping : int, _ih : Boolean, _room : int) : void
		{
			var len : int = userId.length, r = len;
			for (var i : int = 0; i < len; i++)
				if (userId[i] == _id) {
					r = i;
					break;
				}
			if (r == len) {
				trace("here?");
				userId.push(_id);
				var text : TextField = new TextField(777, 51, "", "Courier New", 22);
				var ghostText : String = "Human";
				var hostText : String = "";
				if (_ig) {
					ghostText = "Ghost";
					text.color = Color.RED;
				} else 
					text.color = Color.WHITE;
				if (_ih) {
					hostText = "Host";
				} else hostText = "Guest";
				text.text = fixLength(String(_id), 3) + "      " + fixLength(_name, 12) + "      " + fixLength(ghostText, 5) + "      " + fixLength(String(_ping), 4) + "ms" + "      " + fixLength(hostText, 5);
				text.bold = true;
				text.x = 100;
				text.y = nextY; nextY += 30;
				text.hAlign = HAlign.CENTER;  // 横向对齐
				text.vAlign = VAlign.CENTER; // 纵向对其
				text.border = false;
				textList.push(text);
				//trace(text.text);
				addChild(text);
			 } else {
				 trace("here!");
				 var text : TextField = textList[r];
				 var ghostText : String = "Human";
				 if (_ig) {
					 ghostText = "Ghost";
					 text.color = Color.RED;
				 } else 
					 text.color = Color.WHITE;
				 var hostText : String = "";
				 if (_ih) {
					 hostText = "Host";
				 } else hostText = "Guest";
				 text.text = fixLength(String(_id), 3) + "      " + fixLength(_name, 12) + "      " + fixLength(ghostText, 5) + "      " + fixLength(String(_ping), 4) + "ms" + "      " + fixLength(hostText, 5);
			 }
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}		
		public function onEnterFrame(event:EnterFrameEvent) : void
		{
			//if newWorkUse
			if (false) {
				//director.mySocket.sendRoomMessage(myId, myName, isGhost, ping, isHost, room);
			}
		}
		
		public function removeUser(_id : int) : void
		{
			var len : int = userId.length, r = len;
			for (var i : int = 0; i < len; i++)
				if (userId[i] == _id) {
					removeChild(textList[i]);
					for (var j : int = i; j < len - 1; j++) {
						userId[j] = userId[j + 1];
						textList[j] = textList[j + 1];
						textList[j].y -= 30;
					}
					userId.pop();
					textList.pop();
					nextY -= 30;
					return;
				}
		}
		private function onExit(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (exitButton.filter == null)
					exitButton.filter = BlurFilter.createGlow();
				if (myTouch.phase == "began") {
					//director.mainStage.dropMessage();
					if (director.networkUse)
						director.mySocket.sendQuitMessage(myId, myName, isGhost, ping, isHost, room);
					director.clear();
				}
				//trace(myTouch.phase );
			} else {
				exitButton.filter = null;
			}
		}
		private function onGhost(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (ghostButton.filter == null)
					ghostButton.filter = BlurFilter.createGlow();
				if (myTouch.phase == "began") {
					isGhost = true;
					director.mySocket.sendRoomMessage(myId, myName, isGhost, ping, isHost, room);
					//director.clear();
				}
				//trace(myTouch.phase );
			} else {
				ghostButton.filter = null;
			}
		}
		private function onHuman(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (humanButton.filter == null)
					humanButton.filter = BlurFilter.createGlow();
				if (myTouch.phase == "began") {
					isGhost = false;
					director.mySocket.sendRoomMessage(myId, myName, isGhost, ping, isHost, room);
				}
				//trace(myTouch.phase );
			} else {
				humanButton.filter = null;
			}
		}
		private function onStart(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (hostButton.filter == null)
					hostButton.filter = BlurFilter.createGlow();
				if (myTouch.phase == "began") {
					director.gameState = 1;
					if (director.networkUse)
						director.mySocket.sendStartMessage();
					else {
						//director.networkUse = true;
						director.gameState = 1;
						director.gameStart(false, 0);
					}
				}
				//trace(myTouch.phase );
			} else {
				hostButton.filter = null;
			}
		}
		public var head : int = 0;
		public var tail : int = 0;
		private function onKeyDownHandle(e:KeyboardEvent):void 
		{
			if (e.keyCode == 69) { // e
//				head = head + 1;
	//			addUser(head, String(head), head % 2, head * 10, isHost, head % 2);
			} else if (e.keyCode == 70) { // f
				//this.updateMine(myId, myName, isGhost, ping, true, room);
			} else if (e.keyCode == 68) { // d
				//tail = tail + 1;
				//removeUser(tail);
			}
		}
		
		public var nextY : int = 60;
		public var userId : Vector.<int>;
		public var textList : Vector.<TextField>;
		public var roomInfo : TextField;
		
		
		public var room : int = -1;
		public var myId : int = -1;
		public var myName : String = "";
		public var isGhost : Boolean = false;
		public var ping : int = 0;
		public var isHost : Boolean = false;
		public var hostFlag : Boolean = false;
		
		public var hostButton : TextField;
		public var exitButton : TextField;
		public var humanButton : TextField;
		public var ghostButton : TextField;
		
		public var roomName : String;
		public var director : Director;
	}
}