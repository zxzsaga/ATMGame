package
{
	import starling.display.Image;
	import starling.display.Sprite;

	public class DeadSpace extends Sprite
	{
		public function DeadSpace()
		{
		}
		public function addBloody(_x : int, _y : int) : void{
			trace("!!");
			var a : Image = new Image(Assets.getTexture("bloodyGround"));
			a.x = _x;
			a.y = _y;
			addChild(a);
			bloodyList.push(a);
		}
		public var bloodyList : Vector.<Image> = new Vector.<Image>();
	}
}