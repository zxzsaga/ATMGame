package
{
	import feathers.controls.TextInput;
	
	import starling.display.Image;
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
			var empty : TextField = new TextField(1500, 1002, "", "Courier New", 51);
			empty.touchable = false;
			addChild(empty);
			
			exitButton = new TextField(60, 39, "Exit", "Arial", 33);
			exitButton.touchable = true;
			exitButton.x = 1188;
			exitButton.y = 555;
			exitButton.hAlign = HAlign.CENTER;  // 横向对齐
			exitButton.vAlign = VAlign.CENTER; // 纵向对其
			exitButton.border = false;
			exitButton.addEventListener(TouchEvent.TOUCH, onExit);
			addChild(exitButton);

			//userBoard
			
			userBoard.x = 100;
			userBoard.y = 100;
			userBoard.width = 800;  
			userBoard.height = 399;
			userBoard.backgroundSkin = new Image(Assets.getTexture("boardBG"));
			userBoard.textEditorProperties.color = 0xFFFFFF;  
			userBoard.textEditorProperties.fontSize = 21;
			userBoard.text = "";
			
			
			var tex : String = "";
			tex = "ID" + "      ";
			tex = tex + "    name    " + "      ";
				tex = tex + "status      ";
			tex = tex + " PING ";
			
			userNameHint = new TextField(500, 33, tex, "Courier New", 18);
			userNameHint.color = Color.BLACK;
			userNameHint.border = true;
			userNameHint.bold = true;
			userNameHint.x = 120;
			userNameHint.y = nextY - 30;
			userNameHint.hAlign = HAlign.LEFT;
			//if (director.mainStage.showBoard)
				//addChild(userNameListEl);
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
		public function addUserBoard() : void
		{
			var len : int = userNameList.length;
			for (var i : int = 0; i < len; i++)
				addChild(userNameList[i]);
			addChild(userNameHint);
			trace("?");
		}
		public function removeUserBoard() : void
		{
			var len : int = userNameList.length;
			for (var i : int = 0; i < len; i++)
				removeChild(userNameList[i]);
			removeChild(userNameHint);
		}
		public function removeUser(_id : int) : void
		{
			var len : int = userNameList.length;
			for (var i : int = 0; i < len; i++)
				if (userId[i] == _id) {
					nextY -= 30;
					if (director.mainStage.showBoard)
						removeChild(userNameList[i]);
					for (var j : int = i; j < len - 1; j++) {
						userNameList[j] = userNameList[j + 1];
						userNameList[j].y -= 30;
						userId[j] = userId[j + 1]; 
					}
					userId.pop();
					userNameList.pop();
					break;
				}
		}
		public function fixLength(a : String, _len : int) : String
		{
			if (a.length < _len) {
				var s : String = "";
				for (var l : int = _len - a.length; l >= 0; l--) {
					s += " ";
				}
				//trace(s + "!" + a);
				return a + s; 
			} else return a;
		}
		public function addUser(_id : int, _name : String, _al : Boolean, _ig : Boolean, _ping) : void
		{
			var tex : String = "";
			tex = fixLength(String(_id), 3) + "      ";
			tex = tex + fixLength(_name, 12) + "      ";
			if (_al)
				tex = tex + "alive      ";
			else
				tex = tex + " dead      ";
			tex = tex + fixLength(_ping, 4) + "ms";
			//trace(tex);
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
				var userNameListEl : TextField = new TextField(500, 33, tex, "Courier New", 18);
				nextY += 30;
				if (_id == myId)
					userNameListEl.color = Color.BLUE;
				else if (_ig)
					userNameListEl.color = Color.RED;
				else {
					userNameListEl.color = Color.GREEN;
				}
				userNameListEl.border = false;
				userNameListEl.bold = true;
				userNameListEl.x = 120;
				userNameListEl.y = nextY;
				userNameListEl.hAlign = HAlign.LEFT;
				if (director.mainStage.showBoard)
					addChild(userNameListEl);
				userNameList.push(userNameListEl);
				userId.push(_id);
			}
		}
		public var nextY : int = 120;
		public var userNameList : Vector.<TextField> = new Vector.<TextField>();
		public var userId : Vector.<int> = new Vector.<int>();
		
		public var userNameHint : TextField;
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
		
		public var userBoard : TextInput = new TextInput();
		
	}
}