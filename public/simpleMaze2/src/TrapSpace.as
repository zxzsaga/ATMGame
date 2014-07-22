package
{
	import flash.utils.setTimeout;
	
	import starling.display.Image;
	import starling.display.Sprite;

	public class TrapSpace extends Sprite
	{
		public var isGhost : Boolean;
		public var obWallList : Object;
		public function TrapSpace()
		{
			obWallList = new Object();
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
		public function addTower(_x : int, _y : int) : void
		{
			//trace("why " + isGhost);
			if (isGhost) {
				var a : Image = new Image(Assets.getTexture("unableGround"));
				a.x = 30 + _x * 9;
				a.y = 15 + _y * 9;
				addChild(a);
				obWallList[_x * 200 + _y] = true;
				//obWallList
				trace("set " + a.x + " " + a.y);
			}
		}
		public function isObWall(_x : int, _y : int) : Boolean
		{
			trace(_x + " " + _y + " ? " + obWallList.hasOwnProperty(_x * 200 + _y));
			if (isGhost && obWallList.hasOwnProperty(_x * 200 + _y)) {
				return true;
				//obWallList
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
		public function humanActTrap(_x : int, _y : int) : void {
			var a : Image = new Image(Assets.getTexture("actTrapGround"));
			a.x = _x;
			a.y = _y;
			actTrapList.push(a);
			addChild(a);
			setTimeout(removeTrap, 3000);
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