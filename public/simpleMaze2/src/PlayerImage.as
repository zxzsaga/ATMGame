package
{
	import starling.display.Image;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class PlayerImage
	{
		public function PlayerImage(_id : int, _x : int, _y : int, _name : String, _ig : Boolean)
		{
			playerImage = new Image(Assets.getTexture('player'));
			playerImage.x = _x;
			playerImage.y = _y;
			id = _id;
			
			nameField = new TextField(100, 30, _name, "Arial", 12);
			nameField.color = Color.GREEN;
			if (_ig)
				nameField.color = Color.RED;
			nameField.bold = true;
			nameField.x = playerImage.x - 50;
			nameField.y = playerImage.y - 30;
			nameField.hAlign = HAlign.CENTER;  // 横向对齐
			nameField.vAlign = VAlign.CENTER; // 纵向对其
			nameField.border = false;
			//addChild(nameField);
			
		}
		public var id;
		public var nameField : TextField;
		public var playerImage : Image;
	}
}