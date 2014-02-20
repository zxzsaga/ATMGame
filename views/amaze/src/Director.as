package
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.system.fscommand;
	import flash.utils.Timer;
	
	import flashx.textLayout.formats.BackgroundColor;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.*;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class Director extends Sprite
	{
		public function Director() : void
		{
			super();
			frame = 0;
			initialize();
		}
		public var myFilter : SpotlightFilter;
		public function initialize() : void
		{
			var dx : uint;
			var dy : uint;
			//this.flatten();
			myTimer = new TextField(200, 40, fixTime(0), "Arial", 27);
			fpsText = new TextField(200, 40, "fps: 30", "Arial", 27);
			myFilter = new SpotlightFilter();
			this.filter = myFilter;
			dx = 30;
			dy = 15;
			maze = new RPMazeCreater();
			maze.createMaze(62, 33);
			ex = maze.ex;
			ey = maze.ey;
			myFilter.x = dx + maze.sx * 9 + 4;
			myFilter.y = dy + maze.sy * 9 + 4;
			player_icon = new Image(Assets.getTexture('player'));
			player_icon.x = dx + maze.sx * 9 + 2;
			player_icon.y = dy + maze.sy * 9 + 2;
			var limitx : int;
			limitx = 125;
			var limity : int;
			limity = 67;
			var c1 : int;
			c1 = 0;
			var c2 : int;
			c2 = 0;
			mazeImage = new Array(limitx * limity + 1);
			for (var i : int = 0; i < limitx; i++)
				for (var j : int = 0; j < limity; j++)
					if (maze._mazeMap[i][j]) {
						//var a : Image = new Image(Assets.getTexture("unableGround"));
						mazeImage[i * limity + j] = new Image(Assets.getTexture("unableGround"));
						mazeImage[i * limity + j].x = dx + 9 * i;
						mazeImage[i * limity + j].y = dy + 9 * j;
						if (c1 < 8000)
							quadBatch11.addImage(mazeImage[i * limity + j]);
						else
							quadBatch12.addImage(mazeImage[i * limity + j]);
						c1 = c1 + 1;
						//trace("?1");
					} else {
						mazeImage[i * limity + j] = new Image(Assets.getTexture("ableGround"));
						mazeImage[i * limity + j].x = dx + 9 * i;
						mazeImage[i * limity + j].y = dy + 9 * j;
						if (c2 < 8000)
							quadBatch21.addImage(mazeImage[i * limity + j]);
						else
							quadBatch22.addImage(mazeImage[i * limity + j]);
						c2 += 1;
						//trace("?2");
					}
			addChild(quadBatch11);
			addChild(quadBatch12);
			addChild(quadBatch21);
			addChild(quadBatch22);
			end_icon = new Image(Assets.getTexture("ending"));
			end_icon.x = dx + 9 * maze.ex;
			end_icon.y = dy + 9 * maze.ey;
			addChild(end_icon);
			addChild(player_icon);
			
			myTimer.x = 1150;
			myTimer.y = 30;
			myTimer.hAlign = HAlign.CENTER;  // 横向对齐
			myTimer.vAlign = VAlign.CENTER; // 纵向对其
			myTimer.border = false;
			addChild(myTimer);
			
			
			fpsText.x = 1150;
			fpsText.y = 600;
			fpsText.hAlign = HAlign.CENTER;  // 横向对齐
			fpsText.vAlign = VAlign.CENTER; // 纵向对其
			fpsText.border = false;
			addChild(fpsText);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandle);
			addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandle);
			
			bgm = Assets.getSound("maze");
			bgm_channel = bgm.play(0, 2147483640);
		}
		public function fixTime(a : Number) : String
		{
			var second : int = int(a);
			var minitus : int = second / 60;
			second %= 60;
			var hours : int = minitus / 60;
			minitus %= 60;
			hours = Math.min(hours, 99);
			var p1 : String;
			if (hours < 10) p1 = "0" + String(hours);
			else p1 = String(hours);
			var p2 : String;
			if (minitus < 10) p2 = "0" + String(minitus);
			else p2 = String(minitus);
			var p3 : String;
			if (second < 10) p3 = "0" + String(second);
			else p3 = String(second);
			return p1 + ":" + p2 + ":" + p3;
		}
		public function check(al : int, ar : int, bl : int, br : int) :Boolean 
		{
			//trace(al, ar, bl, br);
			return Math.max(al, bl) < Math.min(ar, br); 
		}
		var sum : Number = 0;
		public function onEnterFrame(event:EnterFrameEvent) : void
		{
			if (!overFlag)
				myTimer.text = fixTime(frame_real);
			frame_real += event.passedTime;
			sum += event.passedTime;
			if (frame % 10 == 0) {
				var a : int = int(1.0 / sum * 10 * 100);
				fpsText.text = "fps: " + String(int(a / 100)) + "." + String(a % 100);
				sum = 0;
			}
			//trace(frame);
			frame = frame + 1;
			var dx : Number = 0;
			var dy : Number = 0;
			for (var i : int = 0; i < 2; i++) {
				if (dir_press[i] == -1 && dir_press[i + 2] == -1) continue;
				if (dir_press[i] > dir_press[i + 2]) {
					dx = dx + dir_x[i];
					dy = dy + dir_y[i];
				} else {
					dx = dx + dir_x[i + 2];
					dy = dy + dir_y[i + 2];
				}
			}
			//var len : Number = Math.sqrt(dx * dx + dy * dy);
			//dx /= len;
			//dy /= len;
			//trace(myFilter.centerX );
			//trace(myFilter.centerY );
			var times : int = 0;
			if (plane_rush_flag) {
				times = 5;
				/*myFilter.centerX += dx * 5;
				myFilter.centerY += dy * 5;
				player_icon.x += dx * 5;
				player_icon.y += dy * 5;*/
			} else {
				times = 3;
				/*myFilter.centerX += dx * 3;
				myFilter.centerY += dy * 3;
				player_icon.x += dx * 3;
				player_icon.y += dy * 3;*/
			}
			for (var i : int = 0; i < times; i++) {
				var tx : int = (player_icon.x - 30) / 9;
				var ty : int = (player_icon.y - 15) / 9;
				var flag : int = 1;
				for (var xx : int = -1; xx <= 1; xx++)
					for (var yy : int = -1; yy <= 1; yy++)
						if (maze._mazeMap[tx + xx][ty + yy])
							if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x + dx, player_icon.x + 4 + dx)
								&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y, player_icon.y + 4))
								flag = 0;
				if (flag == 1) player_icon.x += dx;
				
				flag = 1;
				for (var xx : int = -1; xx <= 1; xx++)
					for (var yy : int = -1; yy <= 1; yy++)
						if (maze._mazeMap[tx + xx][ty + yy])
							if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x, player_icon.x + 4)
								&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y + dy, player_icon.y + 4 + dy))
								flag = 0;
				if (flag == 1) player_icon.y += dy;
			}
			if (myFilter != null) {
				myFilter.x = player_icon.x;
				myFilter.y = player_icon.y;
			}
			if (check(30 + ex * 9, 30 + ex * 9 + 9, player_icon.x, player_icon.x + 4)
				&& check(15 + ey * 9, 15 + ey * 9 + 9, player_icon.y, player_icon.y + 4)) {
				overText = new TextField(200, 40, "Success!", "Arial", 27);
				overText.x = 1150;
				overText.y = 90;
				overFlag = true;
				addChild(overText);
				this.filter = null;
			}
		}
		private function onKeyUpHandle(e:KeyboardEvent):void 
		{
			if (e.keyCode == 37) { // left
				dir_press[0] = -1;
				//game_box.plane.plane_move(-1, 0);
			} else if (e.keyCode == 38) { // up
				dir_press[1] = -1;
			} else if (e.keyCode == 39) { // right
				dir_press[2] = -1;
			} else if (e.keyCode == 40) { // down
				dir_press[3] = -1;
			} else if (e.keyCode == 90) { // z
				this.filter = myFilter;
			} else if (e.keyCode == 16) { // shift
				plane_rush_flag = true;
			}
		}
		private function onKeyDownHandle(e:KeyboardEvent):void 
		{
			if (e.keyCode == 37) { // left
				if (dir_press[0] == -1)
					dir_press[0] = frame;
				//game_box.plane.plane_move(-1, 0);
			} else if (e.keyCode == 38) { // up
				if (dir_press[1] == -1)
					dir_press[1] = frame;
			} else if (e.keyCode == 39) { // right
				if (dir_press[2] == -1)
					dir_press[2] = frame;
			} else if (e.keyCode == 40) { // down
				if (dir_press[3] == -1)
					dir_press[3] = frame;
			} else if (e.keyCode == 90) { // z
				this.filter = null;
			} else if (e.keyCode == 16) { // shift
				plane_rush_flag = false;
			}
		}
		public var quadBatch11 : QuadBatch = new QuadBatch();
		public var quadBatch12 : QuadBatch = new QuadBatch();
		public var quadBatch21 : QuadBatch = new QuadBatch();
		public var quadBatch22 : QuadBatch = new QuadBatch();
		public var player_icon : Image;
		public var end_icon : Image;
		public const dir_x : Array = new Array(-1, 0, 1, 0);
		public const dir_y : Array = new Array(0, -1, 0, 1);
		public var dir_press : Array = new Array(-1, -1, -1, -1);
		public var plane_rush_flag : Boolean = true;
		
		public var mazeImage : Array;
		public var maze : RPMazeCreater;
		public var frame : int = 0;
		public var ex : int = 0;
		public var ey : int = 0;
		public var frame_real : Number = 0;
		public var myTimer : TextField;
		public var overText : TextField;
		public var fpsText : TextField;
		public var overFlag : Boolean = false;
		
		public var bgm : Sound; //bgm音轨
		public var bgm_channel : SoundChannel; //bgm音轨
		
	}
}
