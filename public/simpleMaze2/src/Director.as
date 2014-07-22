package
{
	import feathers.controls.TextInput;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.fscommand;
	import flash.utils.Timer;
	import flash.events.TimerEvent;  
	import flash.text.TextFieldAutoSize
	 
	
	import flashx.textLayout.formats.BackgroundColor;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class Director extends Sprite
	{
		public var mySocket : MySocket;
		public function Director()
		{
			super();
			initialize();
		}
		public function initialize() : void
		{
			
			//this.touchable = false;
			//
			failedInfo = null;
			gameState = -1;
			titleBG = new Image(Assets.getTexture("titleBG"));
			titleBG.touchable = false;
			//titleBG.x = 50;
			//titleBG.y = 50;
			addChild(titleBG);
			
			var empty : TextField = new TextField(1500, 1002, "", "Arial", 51);
			empty.touchable = false;
			addChild(empty);
			
			
			startButton = new Image(Assets.getTexture("start1"));
			startButton.x = 601;
			startButton.y = 369;
			startButton.addEventListener(TouchEvent.TOUCH, startButtonHL);
			
			startMoveButton = new Image(Assets.getTexture("start2"));
			startMoveButton.x = 601;
			startMoveButton.y = 369;
			startMoveButton.addEventListener(TouchEvent.TOUCH, startButtonHL);
			
			addChild(startButton);
			
			
			howButton = new Image(Assets.getTexture("howtoplay1"));
			howButton.x = 501;
			howButton.y = 471;
			howButton.addEventListener(TouchEvent.TOUCH, helpButtonHL);
			
			howMoveButton = new Image(Assets.getTexture("howtoplay2"));
			howMoveButton.x = 501;
			howMoveButton.y = 471;
			howMoveButton.addEventListener(TouchEvent.TOUCH, helpButtonHL);
			
			addChild(howButton);
			
			howFlag = false;
			
			inputName = new TextInput();
			inputName.x = 611 - 5;
			inputName.y = 171 + 5 + 3;
			inputName.width = 222;  
			inputName.height = 51;
			inputName.maxChars = 12;
			inputName.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
			inputName.textEditorProperties.color = 0xFFFFFF;  
			inputName.textEditorProperties.fontSize = 33;
			inputName.text = "your name";
			addChild(inputName);
			
			var inputHint : TextField = new TextField(102, 75, "User: ", "Arial", 33);
			inputHint.color = Color.WHITE;
			inputHint.x = 500;
			inputHint.y = 168;
			addChild(inputHint);
			

			roomName = new TextInput();
			roomName.x = 610 - 5;
			roomName.y = 261 + 5 + 3;
			roomName.width = 222;  
			roomName.height = 51;
			roomName.maxChars = 1;
			//roomName.alignPivot("center", "center");
			roomName.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
			roomName.textEditorProperties.color = 0xFFFFFF;  
			roomName.textEditorProperties.fontSize = 33;
			roomName.text = "1";
			roomName.restrict = "0-9";
			addChild(roomName);
			
			
			var inputHint2 : TextField = new TextField(100, 75, "Room: ", "Arial", 33);
			inputHint2.color = Color.WHITE;
			inputHint2.x = 500;
			inputHint2.y = 258;
			addChild(inputHint2);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandle);
			
			
			refreshHint = new TextField(120, 75, "Refresh", "Arial", 33);
			refreshHint.color = Color.WHITE;
			refreshHint.x = 198;
			refreshHint.y = 438;
			addChild(refreshHint);
			refreshHint.addEventListener(TouchEvent.TOUCH, onRefresh);

			
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandle);
			
			roomBoardBg = new TextInput();
			roomBoardBg.height = 399;
			roomBoardBg.width = 399;
			roomBoardBg.x = 50;
			roomBoardBg.y = 30;
			roomBoardBg.touchable = false;
			roomBoardBg.isEditable = false;
			roomBoardBg.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
			roomBoardBg.textEditorProperties.color = 0xFFFFFF;  
			roomBoardBg.textEditorProperties.fontSize = 30;  
			roomBoardBg.textEditorProperties.fontName = "Arial";
			
			roomBoard = new TextField(399, 399, " 房间\t玩家\t状态\n\t\tnone");
			//roomBoard = new TextField(399, 399, "abcde");
			roomBoard.color = 0xFFFFFF;
			roomBoard.x = 50;
			roomBoard.y = 30;
			roomBoard.fontSize = 30;
			roomBoard.vAlign = "top";
			roomBoard.hAlign = "left";
			roomBoard.touchable = false;
			//roomBoard.border = true;
			
			addChild(roomBoardBg);
			addChild(roomBoard);
		}
		public var roomBoardBg : TextInput;
		public var roomBoard : TextField;
		public var refreshHint : TextField; 
		//private function what(eventObject:TouchEvent):void {
		//}
		private function onRefresh(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (refreshHint.filter == null)
					refreshHint.filter = BlurFilter.createGlow();
				if (myTouch.phase == "began") {
					var request:URLRequest = new URLRequest("http://218.244.133.160:8001/getRooms");
					
					request.data = "refresh";
					request.method = "POST";
					var loader:URLLoader = new URLLoader();
					loader.load(request);
					loader.addEventListener(Event.COMPLETE,completeHandler);
					function completeHandler(event:Event):void {
						trace(loader.data);
						var a : Object = JSON.parse(loader.data);
						var roomList : Array = a.rooms;
						var text : String = " 房间\t玩家\t状态\n";
						if (roomList.length == 0) {
							roomBoard.text = " 房间\t玩家\t状态\n\t\t\tnone";
							return;
						}
						for (var i : int = 0; i < roomList.length; i++) {
							text += " " + roomList[i].room + "\t\t" + roomList[i].player + "\t\t" + roomList[i].status + "\n";
						}
						roomBoard.text = text;
						/*if (text.length < 3)
							roomBoard.text = "   房间       玩家数量     状态\n                     none";
						else
							*/
					}
				}
				//trace(myTouch.phase );
			} else {
				refreshHint.filter = null;
			}
		}
		
		public function warning() : void
		{
			failedInfo = new TextField(202, 151, "DROP FROM THE SERVER!", "Arial", 33);
			failedInfo.x = 850;
			failedInfo.y = 198;
			addChild(failedInfo);
		}
		private function startButtonHL(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (!startFlag) {
					if (gameState == -1) {
						startFlag = true;
						removeChild(startButton);
						addChild(startMoveButton);
					}
				}
				if (myTouch.phase == "began") {
					/*
					removeChildren();
					removeEventListeners();
					roomMenu = new RoomMenu();
					roomMenu.initialize(this, roomName.text);
					addChild(roomMenu);
					*/
					gameState = -1;
					userName = inputName.text;
					mySocket = new MySocket(this); 	
					/*if (networkUse)
						mySocket.sendJoinMessage(roomName.text);
					else {
						removeChildren();
						removeEventListeners();
						roomMenu = new RoomMenu();
						roomMenu.initialize(this, roomName.text);
						addChild(roomMenu);
					}*/
				}
				//trace(myTouch.phase );
			} else {
				if (gameState == -1) {
					startFlag = false;
					addChild(startButton);
					removeChild(startMoveButton);
				}
			}
		}
		public function createRoom() : void
		{
			removeChildren();
			removeEventListeners();
			roomMenu = new RoomMenu();
			roomMenu.initialize(this, roomName.text);
			addChild(roomMenu);
		}
		public function gameStart(_ig : Boolean, _seed : int) : void
		{
			removeChildren();
			removeEventListeners();
			trapSpace = new TrapSpace();
			trapSpace.isGhost = _ig;
			textSpace = new TextSpace();
			if (_ig) {
				mainStage = new GameStage(this, inputName.text, textSpace, trapSpace, true);
			} else 
				mainStage = new GameStage(this, inputName.text, textSpace, trapSpace, false);
			mainStage.seed = _seed;
			textSpace.initialize(this);
			addChild(mainStage);
			addChild(trapSpace);
			addChild(textSpace);
			//if (!networkUse) {
			//}
		}
		private function helpButtonHL(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (!howFlag) {
					howFlag = true;
					removeChild(howButton);
					addChild(howMoveButton);
				}
				//if (howButton.filter == null)
//					howButton.filter = BlurFilter.createGlow();
				if (myTouch.phase == "began") {
					if (helpText == null) {
						//helpText = new TextField(500, 200, "简单的小迷宫的简单介绍：\n人类目标：躲避幽灵设置的陷阱，找到迷宫出口；\n幽灵目标：找到人类，并杀死所有人！\n\n\n按z键退出帮助", "Arial", 33);
						helpText = new TextInput();
						helpText.height = 499;
						helpText.width = 1100;
						helpText.x = 101;
						helpText.y = 30;
						helpText.isEditable = false;
						helpText.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
						helpText.textEditorProperties.color = 0xFFFFFF;  
						helpText.textEditorProperties.fontSize = 33;
						helpText.text = "简单的小迷宫的简单介绍：\n人类目标：躲避幽灵设置的陷阱，找到迷宫出口，不同橘色有不同能力；\n幽灵目标：幽灵在幽灵形态时可以穿墙，并且无法看到人类也无法被人类看\n到，现身后可以攻击人类（距离接近时即判断人类死亡）。幽灵可以放置陷\n阱，人类接触到陷阱时会发出音效，附近的人类都会听到，且幽灵不论在地\n图何处都可以看到陷阱被处罚，以及对应声效。幽灵还能够进入观测点，获\n得附近的视野，并且不会被人类观察到。\n\n按Z键退出帮助\n案件说明：上下左右移动，\n tab显示玩家信息；\n幽灵：Z键现身，X键附体进入观测点，C键设置陷阱"
						//helpText.hAlign = HAlign.CENTER;  // 横向对齐
						//helpText.vAlign = VAlign.CENTER; // 纵向对其
						//helpText.border = false;
						addChild(helpText);
					}
					
				}
			} else {
				howFlag = false;
				removeChild(howMoveButton);
				addChild(howButton);
			}
		}
		private function onKeyDownHandle(e:KeyboardEvent):void 
		{
			//trace(e.altKey);
			if (e.keyCode == 90) { // z
				if (helpText != null) {
					removeChild(helpText);
					helpText = null;
				}
			}
			if (e.keyCode == 88) { // x
				/*if (helpText != null) {
					removeChild(helpText);
					helpText = null;
				}*/
				networkUse = false;
				gameStart(true, 0);
				mainStage.initialize();
			}
		}
		private var myTimer:Timer = new Timer(1);
		private var networkTime : Number = -1;
		
		public function timerListener (e : TimerEvent):void{
			networkTime = networkTime + 20;
		}
		public function readyPing() : void
		{
			myTimer = new Timer(20);
			networkTime = 0;
			myTimer.addEventListener(TimerEvent.TIMER, timerListener);
			myTimer.start();
		}
		public function calcPing() : int
		{
			trace("!!" + networkTime);
			myTimer.stop();
			myTimer.removeEventListener(TimerEvent.TIMER, timerListener);
			return networkTime;
		}
		public function clear()
		{
			if (mainStage != null) {
				try {
					mainStage.bgm_channel.stop();
				} catch (e : Error) {
					
				} finally {
					
				}
			}
			removeChildren();
			removeEventListeners();
			initialize();
		}
		public var mainStage : GameStage;
		public var roomMenu : RoomMenu;
		
		public var titleBG : Image;
		public var helpText : TextInput = null;
		public var textSpace : TextSpace;
		public var trapSpace : TrapSpace;
		public var startButton : Image;
		public var startMoveButton : Image;
		public var startFlag : Boolean;
		
		public var howButton : Image;
		public var howMoveButton : Image;
		public var howFlag : Boolean;
		
		public var userName : String;
		public var inputName : TextInput;
		public var roomName : TextInput;
		public var networkUse : Boolean;
		public var gameState : int = -1; // -1 for nothing, 0 for waiting, 1 for started
		public var failedInfo : TextField = null;
		public var playerType : int = 0;
		
	}
}