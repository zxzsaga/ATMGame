package
{
	import feathers.controls.TextInput;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.Socket;
	import flash.system.fscommand;
	import flash.utils.Timer;
	
	import flashx.textLayout.formats.BackgroundColor;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.*;
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
			startButton.x = 551;
			startButton.y = 399;
			startButton.addEventListener(TouchEvent.TOUCH, startButtonHL);
			
			startMoveButton = new Image(Assets.getTexture("start2"));
			startMoveButton.x = 551;
			startMoveButton.y = 399;
			startMoveButton.addEventListener(TouchEvent.TOUCH, startButtonHL);
			
			addChild(startButton);
			
			
			howButton = new Image(Assets.getTexture("howtoplay1"));
			howButton.x = 451;
			howButton.y = 501;
			howButton.addEventListener(TouchEvent.TOUCH, helpButtonHL);
			
			howMoveButton = new Image(Assets.getTexture("howtoplay2"));
			howMoveButton.x = 451;
			howMoveButton.y = 501;
			howMoveButton.addEventListener(TouchEvent.TOUCH, helpButtonHL);
			
			addChild(howButton);
			
			howFlag = false;
			
			inputName = new TextInput();
			inputName.x = 561;
			inputName.y = 201;
			inputName.width = 150;  
			inputName.height = 51;
			inputName.maxChars = 12;
			inputName.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
			inputName.textEditorProperties.color = 0xFFFFFF;  
			inputName.textEditorProperties.fontSize = 33;
			inputName.text = "your name";
			addChild(inputName);
			
			var inputHint : TextField = new TextField(102, 51, "User: ", "Arial", 33);
			inputHint.x = 450;
			inputHint.y = 198;
			addChild(inputHint);
			

			roomName = new TextInput();
			roomName.x = 560;
			roomName.y = 291;
			roomName.width = 150;  
			roomName.height = 51;
			roomName.maxChars = 1;
			//roomName.alignPivot("center", "center");
			roomName.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
			roomName.textEditorProperties.color = 0xFFFFFF;  
			roomName.textEditorProperties.fontSize = 33;
			roomName.text = "1";
			roomName.restrict = "0-9";
			addChild(roomName);
			
			
			var inputHint2 : TextField = new TextField(100, 50, "Room: ", "Arial", 33);
			inputHint2.x = 450;
			inputHint2.y = 288;
			addChild(inputHint2);
			//addEventListener(TouchEvent.TOUCH, dispatchMouseEvent);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandle);
		}
		//private function what(eventObject:TouchEvent):void {
		//}
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
					gameState = 0;
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
				mainStage.initialize();
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
						helpText.width = 500;
						helpText.x = 401;
						helpText.y = 109;
						helpText.isEditable = false;
						helpText.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
						helpText.textEditorProperties.color = 0xFFFFFF;  
						helpText.textEditorProperties.fontSize = 33;
						helpText.text = "简单的小迷宫的简单介绍：\n人类目标：躲避幽灵设置的陷阱，找到迷宫出口；\n幽灵目标：找到人类，并杀死所有" +
							"\n人！\n\n按z键退出帮助\n\n案件说明：上下左右移动，tab显示玩家信息；\n幽灵：z键现身，C键设置陷阱";
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
			if (e.keyCode == 90) { // z
				if (helpText != null) {
					removeChild(helpText);
					helpText = null;
				}
			}
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
		
	}
}