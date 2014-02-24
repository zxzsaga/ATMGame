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
		public function Director()
		{
			super();
			initialize();
		}
		public function initialize() : void
		{
			//this.touchable = false;
			//
			var empty : TextField = new TextField(1500, 1002, "", "Arial", 51);
			empty.touchable = false;
			addChild(empty);
			
			startButton = new TextField(201, 60, "Start", "Arial", 51);
			startButton.x = 501;
			startButton.y = 399;
			startButton.hAlign = HAlign.CENTER;  // 横向对齐
			startButton.vAlign = VAlign.CENTER; // 纵向对其
			startButton.border = false;
			startButton.addEventListener(TouchEvent.TOUCH, startButtonHL);
			//addEventListener(TouchEvent.TOUCH, what);
			addChild(startButton);
			
			optionButton = new TextField(201, 60, "Option", "Arial", 51);
			optionButton.x = 501;
			optionButton.y = 501;
			optionButton.hAlign = HAlign.CENTER;  // 横向对齐
			optionButton.vAlign = VAlign.CENTER; // 纵向对其
			optionButton.border = false;
			optionButton.addEventListener(TouchEvent.TOUCH, optionButtonHL);
			addChild(optionButton);
			
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
			roomName.text = "0";
			roomName.restrict = "0-9";
			addChild(roomName);
			
			
			var inputHint2 : TextField = new TextField(100, 50, "Room: ", "Arial", 33);
			inputHint2.x = 450;
			inputHint2.y = 288;
			addChild(inputHint2);
			//addEventListener(TouchEvent.TOUCH, dispatchMouseEvent);
		}
		//private function what(eventObject:TouchEvent):void {
		//}
		private function startButtonHL(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (startButton.filter == null)
					startButton.filter = BlurFilter.createGlow();
				if (myTouch.phase == "began") {
					removeChildren();
					removeEventListeners();
					trapSpace = new TrapSpace();
					textSpace = new TextSpace();
					if (roomName.text == "9") {
						mainStage = new GameStage(inputName.text, textSpace, trapSpace, true);
					} else 
						mainStage = new GameStage(inputName.text, textSpace, trapSpace, false);
					//mainStage.textSpace = textSpace;
					textSpace.initialize(this);
					addChild(mainStage);
					addChild(trapSpace);
					addChild(textSpace);
				}
				//trace(myTouch.phase );
			} else {
				startButton.filter = null;
			}
		}
		private function optionButtonHL(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (optionButton.filter == null)
					optionButton.filter = BlurFilter.createGlow();
			} else {
				optionButton.filter = null;
			}
		}
		public function clear()
		{
			mainStage.bgm_channel.stop();
			removeChildren();
			removeEventListeners();
			initialize();
		}
		public var mainStage : GameStage;
		
		public var textSpace : TextSpace;
		public var trapSpace : TrapSpace;
		public var startButton : TextField;
		public var optionButton : TextField;
		public var inputName : TextInput;
		public var roomName : TextInput;
	}
}