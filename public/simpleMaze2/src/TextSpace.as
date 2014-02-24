package
{
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;


	public class TextSpace extends Sprite
	{
		public function TextSpace()
		{
			super();
			//addEventListener(TouchEvent.TOUCH, what);
			
		} 
		public function initialize(_director : Director)
		{
			director = _director;
			var empty : TextField = new TextField(1500, 1002, "", "Arial", 51);
			empty.touchable = false;
			addChild(empty);
			
			exitButton = new TextField(60, 39, "Exit", "Arial", 33);
			exitButton.touchable = true;
			exitButton.x = 1200;
			exitButton.y = 555;
			exitButton.hAlign = HAlign.CENTER;  // 横向对齐
			exitButton.vAlign = VAlign.CENTER; // 纵向对其
			exitButton.border = false;
			exitButton.addEventListener(TouchEvent.TOUCH, onExit);
			addChild(exitButton);
		}
		private function onExit(eventObject:TouchEvent):void {
			var myTouch:Touch = eventObject.getTouch(this);
			if (myTouch) {
				if (exitButton.filter == null)
					exitButton.filter = BlurFilter.createGlow();
				if (myTouch.phase == "began") {
					director.mainStage.dropMessage();
					director.clear();
				}
				//trace(myTouch.phase );
			} else {
				exitButton.filter = null;
			}
		}
		public function addUser(_id : int, _name : String, _al : Boolean, _ig : Boolean) : void
		{
			var tex : String = "";
			tex = String(_id) + "   ";
			tex = tex + _name + "   ";
			if (_al)
				tex = tex + "alive";
			else
				tex = tex + "dead";
			var flag : Boolean = false;
			var len : int = userNameList.length;
			for (var i : int = 0; i < len; i++)
				if (userId[i] == _id) {
					userNameList[i].text = tex;
					if (_id == myId)
						userNameList[i].color = Color.BLUE;
					else if (_ig)
						userNameList[i].color = Color.RED;
					else {
						userNameList[i].color = Color.GREEN;
					}
					flag = true;
					break;
				}
			if (!flag) {
				var userNameListEl : TextField = new TextField(201, 27, tex, "Arial", 18);
				nextY += 30;
				if (_id == myId)
					userNameListEl.color = Color.BLUE;
				else if (_ig)
					userNameListEl.color = Color.RED;
				else {
					userNameListEl.color = Color.GREEN;
				}
				userNameListEl.bold = true;
				userNameListEl.x = 1150;
				userNameListEl.y = nextY;
				addChild(userNameListEl);
				userNameList.push(userNameListEl);
				userId.push(_id);
			}
		}
		public var nextY : int = 333;
		public var userNameList : Vector.<TextField> = new Vector.<TextField>();
		public var userId : Vector.<int> = new Vector.<int>();
		
		public var exitButton : TextField;
		public var convertCdHint : TextField;
		public var myTimer : TextField;
		public var overText : TextField;
		public var fpsText : TextField;
		public var playerNameText : TextField;
		public var trapHint : TextField;
		public var deadMessage : TextField;
		public var myId : int;
		public var director : Director;
		
	}
}