package
{
	import starling.display.Image;
	import starling.display.Sprite;
	import flash.utils.setTimeout;

	public class TrapSpace extends Sprite
	{
		public function TrapSpace()
		{
		}
		public function trapped(_x : int, _y : int) : Boolean {
			//trace("ask " + _x + " " + y);
			var len : int = trapList.length;
			for (var i : int = 0; i < len; i++) {
				if (trapList[i].x == _x && trapList[i].y == _y) {
					return true;
				}
			}
			return false;
		}
		public function removeTrap() : void {
			//trace("how " + actTrapList.length);
			var a : Image = actTrapList.shift();
			//trace("how " + actTrapList.length);
			removeChild(a);
			//trace("deleted");
		}
		public function actTrap(_x : int, _y : int) : void {
			//trace("here " + _x + " " + _y);
			var len : int = trapList.length;
			for (var i : int = 0; i < len; i++) {
				if (trapList[i].x == _x && trapList[i].y == _y) {
					removeChild(trapList[i]);
				}
			}
			for (var i : int = 0; i < len; i++) {
				if (trapList[i].x == _x && trapList[i].y == _y) {
					trapList[i] = trapList[len - 1];
					trapList.pop();
					len--;
					i--;
				}
			}
			var a : Image = new Image(Assets.getTexture("actTrapGround"));
			a.x = _x;
			a.y = _y;
			actTrapList.push(a);
			addChild(a);
			setTimeout(removeTrap, 3000);
		}
		public function addTrap(_x : int, _y : int) : void
		{
			//trace("add " + _x + " " + _y);
			if (!ghost) return;
			var len : int = trapList.length;
			for (var i : int = 0; i < len; i++) {
				if (trapList[i].x == _x && trapList[i].y == _y) {
					return;
				}
			}
			var a : Image = new Image(Assets.getTexture("trapGround"));
			a.x = _x;
			a.y = _y;
			trapList.push(a);
			addChild(a);
		}
		public var trapList : Vector.<Image> = new Vector.<Image>();
		public var actTrapList : Vector.<Image> = new Vector.<Image>();
		public var ghost : Boolean;
	}
}