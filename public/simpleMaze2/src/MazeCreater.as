package
{
	import starling.errors.AbstractClassError;

	public class MazeCreater
	{
		public var _mazeMap:Array;
		public var x:int;
		public var y:int;
		public var sx:int;
		public var sy:int;
		public var ex:int;
		public var ey:int;
		public var _seed:uint;
		private const MAXRATIO:Number=1/(uint.MAX_VALUE+1);
		public function MazeCreater()
		{
		}
		//产生随机数
		public function rand():Number{
			_seed^=(_seed<<21);
			_seed^=(_seed>>>35);
			_seed^=(_seed<<4);
			return _seed*MAXRATIO;
		}
		public function createTower(_ts : TrapSpace, limitx : int, limity : int) : void
		{
			for (var i : int = 0; i < 5; i++) {
				for (var j : int = 0; j < 3; j++) {
					while (true) {
						var tx : int = int(rand() * (limitx / 5 - 6)) + 3 + i * (limitx / 5);
						var ty : int = int(rand() * (limity / 3 - 6)) + 3 + j * (limity / 3);
						//trace("!" + limitx + " " + limity);
						if (_mazeMap[tx][ty]) {
							_ts.addTower(tx, ty);
							break;
						}
					}
				}
			}
		}
	}
}