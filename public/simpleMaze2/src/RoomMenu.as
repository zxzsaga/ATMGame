package
{
	import feathers.controls.TextInput;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import starling.display.Image;
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
		public var playerTypeName : String = "普通人！";
		public var roomBG : Image;
		public var chatHint : TextField;
		public function initialize(_d : Director, _name : String) : void
		{
			director = _d;
			roomName = _name;
			
			roomBG = new Image(Assets.getTexture("roomBG"));
			roomBG.touchable = false;
			//titleBG.x = 50;
			//titleBG.y = 50;
			addChild(roomBG);
			
			roomInfo = new TextField(120, 60, "Room " + _name, "Arial", 33);
			//roomInfo.touchable = true;
			roomInfo.color = Color.WHITE;
			roomInfo.x = 50;
			roomInfo.y = 10;
			roomInfo.hAlign = HAlign.CENTER;  // 横向对齐
			roomInfo.vAlign = VAlign.CENTER; // 纵向对其
			roomInfo.border = false;
			addChild(roomInfo);
			
			exitButton = new TextField(120, 51, "Exit", "Arial", 33);
			exitButton.color = Color.WHITE;
			exitButton.touchable = true;
			exitButton.x = 1188;
			exitButton.y = 555;
			exitButton.hAlign = HAlign.CENTER;  // 横向对齐
			exitButton.vAlign = VAlign.CENTER; // 纵向对其
			exitButton.border = false;
			exitButton.addEventListener(TouchEvent.TOUCH, onExit);
			addChild(exitButton);
			
			ghostButton = new TextField(150, 51, "幽灵！", "Arial", 33);
			ghostButton.touchable = true;
			ghostButton.color = Color.RED;
			ghostButton.x = 830;
			ghostButton.y = 55;
			ghostButton.hAlign = HAlign.CENTER;  // 横向对齐
			ghostButton.vAlign = VAlign.CENTER; // 纵向对其
			ghostButton.border = true;
			ghostButton.addEventListener(TouchEvent.TOUCH, onGhost);
			addChild(ghostButton);
			
			human0Button = new TextField(150, 51, "普通人！", "Arial", 33);
			human0Button.color = Color.WHITE;
			human0Button.touchable = true;
			human0Button.x = 830;
			human0Button.y = 122;
			human0Button.hAlign = HAlign.CENTER;  // 横向对齐
			human0Button.vAlign = VAlign.CENTER; // 纵向对其
			human0Button.border = true;
			human0Button.addEventListener(TouchEvent.TOUCH, onHuman0);
			addChild(human0Button);
			
			human1Button = new TextField(150, 51, "顺风耳！", "Arial", 33);
			human1Button.color = Color.WHITE;
			human1Button.touchable = true;
			human1Button.x = 830;
			human1Button.y = 192;
			human1Button.hAlign = HAlign.CENTER;  // 横向对齐
			human1Button.vAlign = VAlign.CENTER; // 纵向对其
			human1Button.border = true;
			human1Button.addEventListener(TouchEvent.TOUCH, onHuman1);
			addChild(human1Button);
			
			human2Button = new TextField(150, 51, "千里眼！", "Arial", 33);
			human2Button.color = Color.WHITE;
			human2Button.touchable = true;
			human2Button.x = 830;
			human2Button.y = 262;
			human2Button.hAlign = HAlign.CENTER;  // 横向对齐
			human2Button.vAlign = VAlign.CENTER; // 纵向对其
			human2Button.border = true;
			human2Button.addEventListener(TouchEvent.TOUCH, onHuman2);
			addChild(human2Button);
			
			human3Button = new TextField(150, 51, "阴阳眼！", "Arial", 33);
			human3Button.color = Color.WHITE;
			human3Button.touchable = true;
			human3Button.x = 830;
			human3Button.y = 332;
			human3Button.hAlign = HAlign.CENTER;  // 横向对齐
			human3Button.vAlign = VAlign.CENTER; // 纵向对其
			human3Button.border = true;
			human3Button.addEventListener(TouchEvent.TOUCH, onHuman3);
			addChild(human3Button);
			
			playerHint = new TextField(200, 300, "", "Arial", 30);
			playerHint.color = Color.WHITE;
			playerHint.touchable = true;
			playerHint.x = 1000;
			playerHint.y = 50;
			playerHint.hAlign = HAlign.CENTER;  // 横向对齐
			playerHint.vAlign = VAlign.TOP; // 纵向对其
			playerHint.border = true;
			addChild(playerHint);
			//human3Button.addEventListener(TouchEvent.TOUCH, onHuman3);
			
			
			charBoard = new TextField(500, 200, "", "Arial", 21);
			charBoard.color = Color.WHITE;
			charBoard.x = 688;
			charBoard.y = 402;
			charBoard.hAlign = HAlign.LEFT;  // 横向对齐
			charBoard.vAlign = VAlign.TOP; // 纵向对其
			charBoard.border = true;
			addChild(charBoard);
			charContent = new Vector.<String>();
			
			chatHint = new TextField(51, 51, "=", "Arial", 30);
			chatHint.x = 122-51;
			chatHint.y = 560;
			chatHint.color = Color.WHITE;
			chatHint.border = true;
			addChild(chatHint);
			
			inputChar = new TextInput();
			inputChar.x = 122;
			inputChar.y = 560;
			inputChar.width = 500;  
			inputChar.height = 51;
			inputChar.maxChars = 33;
			inputChar.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
			inputChar.textEditorProperties.color = 0xFFFFFF;  
			inputChar.textEditorProperties.fontSize = 27;
			inputChar.text = "";
			addChild(inputChar);
			
			//charBoard.addEventListener(TouchEvent.TOUCH, onHuman);
			userId = new Vector.<int>();
			textList = new Vector.<TextField>();
			//nextY = 30;
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandle);
			joinBGM = Assets.getSound("join");
			trace("+" + ping);
		}
		public function getChat(a : String, _name : String) : void
		{
			if (charContent.length >= 6) {
				charContent.shift();
			}
			charContent.push(_name + ": " + a + "\n");
			var tmp : String = "";
			for (var i : int = 0; i < charContent.length; i++)
				tmp += charContent[i];
			charBoard.text = tmp;
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
		public function updateMine(_id : int, _name : String, _ig : Boolean, _ping : int, _ih : Boolean, _room : int, _text : String) : void
		{
			myId = _id;
			myName = _name;
			isGhost = _ig;
			//ping = _ping;
			isHost = _ih;
			room = _room;
			playerTypeName = _text;
			//trace("what " + isHost + "  " + !hostFlag);
			if (isHost && !hostFlag) {
				hostButton = new TextField(120, 51, "Start!", "Arial", 33);
				hostButton.touchable = true;
				hostButton.x = 1188;
				hostButton.y = 500;
				hostButton.hAlign = HAlign.CENTER;  // 横向对齐
				hostButton.vAlign = VAlign.CENTER; // 纵向对其
				hostButton.border = false;
				hostButton.color = Color.WHITE;
				hostButton.addEventListener(TouchEvent.TOUCH, onStart);
				addChild(hostButton);
			}
		}
		public function addUser(_id : int, _name : String, _ig : Boolean, _ping : int, _ih : Boolean, _room : int, _text : String) : void
		{
			var len : int = userId.length, r = len;
			for (var i : int = 0; i < len; i++)
				if (userId[i] == _id) {
					r = i;
					break;
				}
			if (_id == myId)
				_ping = ping;
			if (r == len) {
				joinChannel = joinBGM.play();
				userId.push(_id);
				var text : TextField = new TextField(777, 51, "", "Courier New", 18);
				var ghostText : String = "Human";
				var hostText : String = "";
				if (_ig) {
					//ghostText = "Ghost";
					text.color = Color.RED;
				} else 
					text.color = Color.WHITE;
				if (_ih) {
					hostText = "Host";
				} else hostText = "Guest";
				text.text = fixLength(String(_id), 3) + "   " + fixLength(_name, 12) + "   " + fixLength(_text, 6) + "   " + fixLength(String(_ping), 4) + "ms" + "   " + fixLength(hostText, 5);
				text.bold = true;
				text.x = 50;
				text.y = nextY; nextY += 30;
				text.hAlign = HAlign.LEFT;  // 横向对齐
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
				 text.text = fixLength(String(_id), 3) + "   " + fixLength(_name, 12) + "   " + fixLength(_text, 6) + "   " + fixLength(String(_ping), 4) + "ms" + "   " + fixLength(hostText, 5);
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
				playerHint.text = "幽灵\n\n迷宫中的幽灵，需要杀死所有玩家。\nZ变身，X进入观测点，C设置陷阱";
				if (myTouch.phase == "began") {
					isGhost = true;
					director.mySocket.sendRoomMessage(myId, myName, isGhost, ping, isHost, room, ghostButton.text);
					//director.clear();
				}
				//trace(myTouch.phase );
			} else {
				ghostButton.filter = null;
				playerHint.text = "";
			}
		}
		private function onHuman0(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (human0Button.filter == null)
					human0Button.filter = BlurFilter.createGlow();
				playerHint.text = "普通人\n\n我只想做个普通人啊！";
				if (myTouch.phase == "began") {
					isGhost = false;
					director.playerType = 0;
					director.mySocket.sendRoomMessage(myId, myName, isGhost, ping, isHost, room, human0Button.text);
				}
				//trace(myTouch.phase );
			} else {
				human0Button.filter = null;
				playerHint.text = "";
			}
		}
		private function onHuman1(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (human1Button.filter == null)
					human1Button.filter = BlurFilter.createGlow();
				playerHint.text = "顺风耳\n\n可以通过声波锁定除鬼外所有玩家的位置，并且监听全屏范围的被处罚陷阱";
				if (myTouch.phase == "began") {
					isGhost = false;
					director.playerType = 0;
					director.mySocket.sendRoomMessage(myId, myName, isGhost, ping, isHost, room, human1Button.text);
				}
				//trace(myTouch.phase );
			} else {
				human1Button.filter = null;
				playerHint.text = "";
			}
		}
		private function onHuman2(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (human2Button.filter == null)
					human2Button.filter = BlurFilter.createGlow();
				playerHint.text = "千里眼\n\n可以获得比常人更大的视野";
				if (myTouch.phase == "began") {
					isGhost = false;
					director.playerType = 1;
					director.mySocket.sendRoomMessage(myId, myName, isGhost, ping, isHost, room, human2Button.text);
				}
				//trace(myTouch.phase );
			} else {
				human2Button.filter = null;
				playerHint.text = "";
			}
		}
		private function onHuman3(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (human3Button.filter == null)
					human3Button.filter = BlurFilter.createGlow();
				playerHint.text = "阴阳眼\n\n角色可以在一定距离内观测到幽灵，无论现身与否";
				if (myTouch.phase == "began") {
					isGhost = false;
					director.playerType = 2;
					director.mySocket.sendRoomMessage(myId, myName, isGhost, ping, isHost, room, human3Button.text);
				}
				//trace(myTouch.phase );
			} else {
				human3Button.filter = null;
				playerHint.text = "";
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
			} else if (e.keyCode == 13) { // enter
				if (inputChar.text != "") {
					director.mySocket.sendChatMessage(inputChar.text, myName);
					inputChar.text = "";
				}
			} else if (e.keyCode == 70) { // f
				//this.updateMine(myId, myName, isGhost, ping, true, room);
			} else if (e.keyCode == 68) { // d
				//tail = tail + 1;
				//removeUser(tail);
			}
		}
		public var charContent : Vector.<String>;
		
		public var nextY : int = 66;
		public var userId : Vector.<int>;
		public var textList : Vector.<TextField>;
		public var roomInfo : TextField;
		
		public var charBoard: TextField;
		
		public var room : int = -1;
		public var myId : int = -1;
		public var myName : String = "";
		public var isGhost : Boolean = false;
		public var ping : int = 0;
		public var isHost : Boolean = false;
		public var hostFlag : Boolean = false;
		
		public var hostButton : TextField;
		public var exitButton : TextField;
		public var human0Button : TextField;
		public var human1Button : TextField;
		public var human2Button : TextField;
		public var human3Button : TextField;
		public var ghostButton : TextField;
		public var playerHint : TextField;
		
		public var inputChar : TextInput; 
		public var roomName : String;
		public var director : Director;
		
		public var joinBGM : Sound;
		public var joinChannel : SoundChannel;
	}
}