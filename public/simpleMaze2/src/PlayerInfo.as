package
{
	public class PlayerInfo
	{
		public function PlayerInfo(_id : int, _x : int, _y : int, _name : String, _ig : Boolean, _iz : Boolean, _ia : Boolean, _room : int, _seed : int, _ping : int)
		{
			id = _id;
			x = _x;
			y = _y;
			name = _name;
			isGhost = _ig;
			isZombie = _iz;
			alive = _ia;
			room = _room;
			seed = _seed;
			ping = _ping;
		}
		public var ping : int;
		public var isGhost : Boolean;
		public var isZombie : Boolean;
		public var alive : Boolean;
		public var room : int;
		public var seed : int;
		
		public var id : int;
		public var x : int;
		public var y : int;
		public var name : String;
	}
}