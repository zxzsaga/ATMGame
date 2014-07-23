package
{
	import feathers.controls.TextInput;
	
	import flash.events.TimerEvent;  
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.Socket;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
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

	public class GameStage extends Sprite
	{
		
		public var mySocket : MySocket;
		public function GameStage(_director : Director, _name : String = "", _ts : TextSpace = null, _trs : TrapSpace = null, _ig : Boolean = false)
		{
			super();
			isGhost = _ig;
			textSpace = _ts;
			trapSpace = _trs;
			playerName = _name;
			mySocket = _director.mySocket;
			networkUse = _director.networkUse;
			director = _director;
			if (_ig)
				playerType = -1;
			else
				playerType = director.playerType;
			//initialize();
		}
		public var director : Director;
		public var networkUse : Boolean = false;
		public var myFilter : SpotlightFilter;
		public var ghostFilter : SpotlightFilter;
		public var zombieFilter : SpotlightFilter;
		public var obFilter : SpotlightFilter;
		
		public var startFlag : Boolean = false;
		public var isGhost : Boolean = false;
		public var isZombie : Boolean = false;
		public var isOb : Boolean = false;
		public var playerType : int = -1;
		public var deadFlag : Boolean = false;
		
		public var skillConvertCd : Number;
		public var skillConvertLastTime : Number;
		
		public var skillObCd : Number;
		public var skillObLastTime : Number;
		
		public var skillTrap : Number;
		public var skillTrapCd : Number;
		
		public var limitx : int;
		public var limity : int;
		public var inRoom : int = 0;
		public var ping : int = 0;
		
		public var key : int = int(Math.random() * 10000000);
		public var alive : Boolean;
		public function clear() : void
		{
			
		}
		public function initialize(x : int = -1, y : int = -1) : void
		{	
			trace(" seed ! " + seed);
			if (startFlag) return;
			
			textSpace.charBoard = new TextField(300, 200, "", "Arial", 18);
			textSpace.charBoard.color = Color.WHITE;
			textSpace.charBoard.x = 988;
			textSpace.charBoard.y = 332;
			textSpace.charBoard.hAlign = HAlign.LEFT;  // 横向对齐
			textSpace.charBoard.vAlign = VAlign.TOP; // 纵向对其
			textSpace.charBoard.border = true;
			textSpace.addChild(textSpace.charBoard);
			textSpace.charContent = new Vector.<String>();
			
			textSpace.inputChar = new TextInput();
			textSpace.inputChar.x = 32;
			textSpace.inputChar.y = 575;
			textSpace.inputChar.width = 930;  
			textSpace.inputChar.height = 51;
			textSpace.inputChar.maxChars = 33;
			textSpace.inputChar.backgroundSkin = new Image(Assets.getTexture("inputNameBG"));
			textSpace.inputChar.textEditorProperties.color = 0xFFFFFF;  
			textSpace.inputChar.textEditorProperties.fontSize = 27;
			textSpace.inputChar.text = "";
			addChild(textSpace.inputChar);
			
			textSpace.myId = playerId;
			trapSpace.ghost = isGhost;
			if (isGhost) {
				if (networkUse) {
					//mySocket.sendTrapMessage(playerId, -1, -1);
					//mySocket.sendGhostMessage(playerId, -1, -1);
				}
				trace(textSpace);
				textSpace.convertCdHint = new TextField(300, 40, fixTime(0), "Courier New", 15);
				textSpace.convertCdHint.color = Color.BLACK;
				textSpace.convertCdHint.x = 986;
				textSpace.convertCdHint.y = 239;
				textSpace.convertCdHint.hAlign = HAlign.LEFT;  // 横向对齐
				textSpace.convertCdHint.vAlign = VAlign.TOP; // 纵向对其
				textSpace.convertCdHint.border = false;
				textSpace.convertCdHint.text = "Z: 物理形态冷却时间: " + int(int(skillConvertCd * 10) / 10) + "." + int(skillConvertCd * 10) % 10;
				textSpace.addChild(textSpace.convertCdHint);
				
				textSpace.obHint = new TextField(300, 40, fixTime(0), "Courier New", 15);
				textSpace.obHint.color = Color.WHITE;
				textSpace.obHint.x = 986;
				textSpace.obHint.y = 270;
				textSpace.obHint.hAlign = HAlign.LEFT;  // 横向对齐
				textSpace.obHint.vAlign = VAlign.TOP; // 纵向对其
				textSpace.obHint.border = false;
				textSpace.obHint.text = "X: 进入观测点冷却时间: " + "0.0";
				textSpace.addChild(textSpace.obHint);
				
				textSpace.trapHint = new TextField(300, 40, fixTime(0), "Courier New", 15);
				textSpace.trapHint.color = Color.WHITE;
				textSpace.trapHint.x = 986;
				textSpace.trapHint.y = 300;
				textSpace.trapHint.hAlign = HAlign.LEFT;  // 横向对齐
				textSpace.trapHint.vAlign = VAlign.TOP; // 纵向对其
				textSpace.trapHint.border = false;
				textSpace.trapHint.text = "C: 可用陷阱个数: " + skillTrap;
				textSpace.addChild(textSpace.trapHint);
				
				skillConvertCd = 10;
				skillTrap = 5;
				skillTrapCd = 15;
				skillObCd = 5;
			}
			myTimer.addEventListener(TimerEvent.TIMER, timerListener);
			myTimer.start();
			alive = true;
			textSpace.addUser(playerId, playerName, alive, isGhost, ping);
			startFlag = true;
			var dx : uint;
			var dy : uint;
			//this.flatten();
			frame = 0;
			textSpace.myTimer = new TextField(200, 40, fixTime(0), "Arial", 27);
			textSpace.fpsText = new TextField(200, 40, "fps: 30.0", "Arial", 27);
			textSpace.playerNameText = new TextField(100, 30, playerName, "Arial", 12);
			
			if (playerType == 1)
				myFilter = new SpotlightFilter(0, 0, 0.05);
			else
				myFilter = new SpotlightFilter();
			ghostFilter = new SpotlightFilter(0, 0, 0.09);
			ghostFilter.red = 0.01;
			//obFilter = myFilter;
			obFilter = new SpotlightFilter(0, 0, 0.06);
			//obFilter.red = 0.01;
			zombieFilter = new SpotlightFilter(0, 0, 0.09);
			zombieFilter.green = 0.1;
			zombieFilter.red = 0.5;
			if (isGhost)
				this.filter = ghostFilter;
			else
				this.filter = myFilter;
			dx = 30;
			dy = 15;
			//seed = 2;
			if (seed % 3 == 0) {
				maze = new RPMazeCreater();
				(RPMazeCreater(maze)).createMaze(51, 30, -1, -1, seed);
			} else if (seed % 3 == 1) {
				maze = new DFSMazeCreater();
				(DFSMazeCreater(maze)).createMaze(51, 30, -1, -1, seed);
			} else {
				maze = new RDMazeCreater();
				(RDMazeCreater(maze)).createMaze(51, 30, seed);
			}
			trace("??" + maze.ex);
			trace("??" + maze.ey);
			ex = maze.ex;
			ey = maze.ey;
			myFilter.x = dx + maze.sx * 9 + 4;
			myFilter.y = dy + maze.sy * 9 + 4;
			limitx = 103;
			limity = 61;
			maze.createTower(trapSpace, limitx, limity);
			player_icon = new Image(Assets.getTexture('player'));
			if (x == -1 && y == -1) {
				player_icon.x = dx + maze.sx * 9 + 2;
				player_icon.y = dy + maze.sy * 9 + 2;
			} else {
				player_icon.x = x;
				player_icon.y = y;
			}
			if (isGhost) {
				player_icon.x = dx + 60 * 9;
				player_icon.y = dy + 30 * 9;
			}
			var c1 : int;
			c1 = 0;
			var c2 : int;
			c2 = 0;
			//trace("!" + maze._mazeMap.length);
			//trace("!" + maze._mazeMap[0].length);
			mazeImage = new Array(limitx * limity + 1);
			//trapSpace.addTrap(30 * 9 + dx, 30 * 9 + dy);
			//trace(limitx * limity + 1);
			for (var i : int = 0; i < limitx; i++)
				for (var j : int = 0; j < limity; j++) {
					//trace(i);
					//trace(j);
					if (maze._mazeMap[i][j]) {
						//var a : Image = new Image(Assets.getTexture("unableGround"));
						mazeImage[i * limity + j] = new Image(Assets.getTexture("unableGround"));
						mazeImage[i * limity + j].x = dx + 9 * i;
						mazeImage[i * limity + j].y = dy + 9 * j;
						//trace(i * limity + j);
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
						//trace(i * limity + j);
						if (c2 < 8000)
							quadBatch21.addImage(mazeImage[i * limity + j]);
						else
							quadBatch22.addImage(mazeImage[i * limity + j]);
						c2 += 1;
						//trace("?2");
					}
				}
			addChild(quadBatch11);
			addChild(quadBatch12);
			addChild(quadBatch21);
			addChild(quadBatch22);
			
			deadSpace = new DeadSpace();
			addChild(deadSpace);
			
			if (!isGhost) {
				end_icon = new Image(Assets.getTexture("ending"));
				end_icon.x = dx + 9 * maze.ex;
				end_icon.y = dy + 9 * maze.ey;
				addChild(end_icon);
			}
			addChild(player_icon);
			
			textSpace.myTimer.x = 950;
			textSpace.myTimer.y = 30;
			textSpace.myTimer.hAlign = HAlign.CENTER;  // 横向对齐
			textSpace.myTimer.vAlign = VAlign.CENTER; // 纵向对其
			textSpace.myTimer.border = false;
			textSpace.addChild(textSpace.myTimer);
			
			
			textSpace.fpsText.x = 957;
			textSpace.fpsText.y = 585;
			textSpace.fpsText.hAlign = HAlign.CENTER;  // 横向对齐
			textSpace.fpsText.vAlign = VAlign.CENTER; // 纵向对其
			textSpace.fpsText.border = false;
			textSpace.addChild(textSpace.fpsText);
			
			//playerNameText.filter = light;
			if (isGhost) {
				textSpace.playerNameText.color = Color.RED;
			} else
				textSpace.playerNameText.color = Color.BLUE;
			textSpace.playerNameText.bold = true;
			textSpace.playerNameText.x = player_icon.x - 50;
			textSpace.playerNameText.y = player_icon.y - 30;
			textSpace.playerNameText.hAlign = HAlign.CENTER;  // 横向对齐
			textSpace.playerNameText.vAlign = VAlign.CENTER; // 纵向对其
			textSpace.playerNameText.border = false;
			textSpace.addChild(textSpace.playerNameText);
			
			
			
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandle);
			addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandle);
			
			players = new Vector.<PlayerInfo>();
			displayed = new Vector.<Boolean>();
			setTimeout(playMusic, 1000);
			//trace("ini done");
			lighting = Assets.getSound("lighting");
			deadSe = Assets.getSound("screaming_boy");
		}
		public function deadUser(_id : int, _name : String) : void
		{
			var len : int = textSpace.userId.length;
			for (var i : int = 0; i < len; i++) {
				if (textSpace.userId[i] == _id) {
					textSpace.userNameList[i].bold = false;
					var tex : String = "";
					tex = String(_id) + "   ";
					tex = tex + _name + "   ";
					tex = tex + "dead";
					textSpace.userNameList[i].text = tex;
					break;
				}
			}
		}
		public function deadGrid(_x : int, _y : int) : void
		{
			deadSeChannel = deadSe.play();
			var tx : int = (_x - 30) / 9;
			var ty : int = (_y - 15) / 9;
			var mini : Number = 1000000000;
			var bx : int = -1;
			var by : int;
			for (var xx : int = -1; xx <= 1; xx++)
				for (var yy : int = -1; yy <= 1; yy++)
					if (!maze._mazeMap[tx + xx][ty + yy])
						if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, _x, _x + 4)
							&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, _y, _y + 4)) {
							var tmp : Number = sqr(30 + (tx + xx) * 9 + 4.5 - (_x + 2)) + sqr(15 + (ty + yy) * 9 + 4.5 - (_y + 2));
							if (tmp < mini) {
								mini = tmp;
								bx = 30 + (tx + xx) * 9;
								by = 15 + (ty + yy) * 9;
							}
						}
			if (bx != -1)
				deadSpace.addBloody(bx, by);
		}
		public function addDeadMessage() : void
		{
			deadGrid(player_icon.x, player_icon.y);
			deadFlag = true;
			
			//removeEventListeners(KeyboardEvent.KEY_DOWN);
			//removeEventListeners(KeyboardEvent.KEY_UP);
			dir_press = new Array(-1, -1, -1, -1);
			this.alive = false;
			this.filter = null;
			this.removeChild(player_icon);
			var len : int = textSpace.userId.length;
			for (var i : int = 0; i < len; i++) {
				if (textSpace.userId[i] == playerId) {
					var tex : String = "";
					tex = String(playerId) + "   ";
					tex = tex + playerName + "   ";
					tex = tex + "dead";
					textSpace.userNameList[i].bold = false;
					textSpace.userNameList[i].text = tex;
					textSpace.userNameList[i].fontSize = 15;
					break;
				}
			}
			textSpace.deadMessage = new TextField(300, 40, "You died : )", "Arial", 21);
			textSpace.deadMessage.color = Color.RED;
			textSpace.deadMessage.x = 968;
			textSpace.deadMessage.y = 200;
			textSpace.deadMessage.hAlign = HAlign.LEFT;  // 横向对齐
			textSpace.deadMessage.vAlign = VAlign.TOP; // 纵向对其
			textSpace.deadMessage.border = false;
			textSpace.addChild(textSpace.deadMessage);
		}
		public function playMusic() : void
		{
			bgm = Assets.getSound("maze");
			bgm_channel = bgm.play(0, 2147483640);
			
			bgm_voice = new SoundTransform();
			bgm_voice.volume = 0.1;
			bgm_channel.soundTransform = bgm_voice;
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
		public function actTrap(_x : int, _y : int) : void
		{
			if (isGhost) {
				lightingChannel = lighting.play();
				//trace("hi??");
				trapSpace.actTrap(_x, _y);
			} else if (playerType == 0) {
				lightingChannel = lighting.play();
				trapSpace.humanActTrap(_x, _y);
			} else if (sqr(player_icon.x - _x - 5) + sqr(player_icon.y - _y - 5) <= 2199 * 6) {
				lightingChannel = lighting.play();
			}
		}
		public function check(al : int, ar : int, bl : int, br : int) :Boolean 
		{
			//trace(al, ar, bl, br);
			return Math.max(al, bl) < Math.min(ar, br); 
		}
		public function removePlayer(p : PlayerInfo) : void
		{
			if (players.length)
				for (var i : int = players.length - 1; i >= 0; i--) {
					if (players[i].id == p.id) {
						if (displayed[i]) {
							erasePlayer(players[i].id);
						}
						textSpace.removeUser(p.id);
						players[i] = players[players.length - 1];
						/*players[i].x = players[players.length - 1].x;
						players[i].y = players[players.length - 1].y;
						players[i].id = players[players.length - 1].id;
						players[i].name = players[players.length - 1].name;
						players[i].isGhost = players[players.length - 1].isGhost;
						players[i].isZombie = players[players.length - 1].isZombie;
						players[i].alive = players[players.length - 1].alive;
						players[i].room = players[players.length - 1].room;
						players[i].seed = players[players.length - 1].seed;*/
						
						displayed[i] = displayed[players.length - 1];
						displayed.pop();
						players.pop();
					}
				}
		}
		private var sum : Number = 0;
		public function refreshPing(_ping : Number) : void
		{
			ping = int(_ping);
		}
		public function gameOver(winName : String) : void
		{
			overFlag = true;
			textSpace.overText = new TextField(500, 60, winName + " WIN!", "Arial", 27);
			textSpace.overText.x = 989;
			textSpace.overText.y = 90;
			textSpace.overText.hAlign = HAlign.LEFT;  // 横向对齐
			textSpace.overText.vAlign = VAlign.TOP; // 纵向对其
			textSpace.addChild(textSpace.overText);
			this.filter = null;
		}
		private var myTimer:Timer = new Timer(20);
		private var networkTime : Number = 0;
		public function timerListener (e : TimerEvent):void{
			networkTime = networkTime + 20;
		}
		/*private var pingSum : Number = 0;
		private var pingRecvNumber : Number = 0;
		private var pingSendNumber : Number = 0;
		public function refreshPing() : void
		{
			trace("recv " + networkTime);
			pingSum += networkTime;
			var calcSum : Number = pingSum;
			pingRecvNumber = pingRecvNumber + 1;
			var tmp : Number = networkTime;
			
			for (var i : int = pingRecvNumber + 1; i <= pingSendNumber; i++) {
				tmp = tmp + 39;
				calcSum += tmp;
			}
			ping = int(calcSum / pingSendNumber);
		}*/
		public function onEnterFrame(event:EnterFrameEvent) : void
		{
		/*	trace("send " + networkTime);
			pingSendNumber = pingSendNumber + 1;
			pingSum -= networkTime;*/
			//ping += 1;
			//quadBatch11.x -= 1;
			if (director.networkUse && frame - lastUpdate > 300) {
				//director.mainStage.dropMessage();
				director.mainStage.clear();
				director.clear();
				director.warning();
				return;
			}
/*			if (skillSeeCd <= 0) {
				isSee = true;
				skillSeeCd = 15;
				skillSeeLast = 5;
			}*/
			if (isGhost) {
				skillConvertCd -= event.passedTime;
				skillTrapCd -= event.passedTime;
				skillObCd -= event.passedTime;
				if (skillTrapCd < 0) {
					skillTrapCd += 15;
					skillTrap++;
				}
				if (skillConvertCd < 0) {
					if (textSpace.convertCdHint.color != Color.WHITE) {
						//removeChild(convertCdHint);
						textSpace.convertCdHint.color = Color.WHITE;
						//addChild(convertCdHint);
					}
					skillConvertCd = 0;
				} else {
					if (textSpace.convertCdHint.color != Color.BLACK) {
						//removeChild(convertCdHint);
						textSpace.convertCdHint.color = Color.BLACK;
					//	addChild(convertCdHint);
					}
				}
				
				if (skillObCd < 0) {
					if (textSpace.obHint.color != Color.WHITE) {
						textSpace.obHint.color = Color.WHITE;
					}
					skillObCd = 0;
				} else {
					if (textSpace.obHint.color != Color.BLACK) {
						textSpace.obHint.color = Color.BLACK;
					}
				}
				textSpace.obHint.text = "X: 进入观测点冷却时间: " + int(int(skillObCd * 10) / 10) + "." + int(skillObCd * 10) % 10;
				
				if (skillTrap == 0)
					textSpace.trapHint.color = Color.BLACK;
				else
					textSpace.trapHint.color = Color.WHITE;
				textSpace.trapHint.text = "C: 可用陷阱个数: " + skillTrap;
				textSpace.convertCdHint.text = "Z: 物理形态冷却时间: " + int(int(skillConvertCd * 10) / 10) + "." + int(skillConvertCd * 10) % 10;
			}
			if (isOb) {
				skillObLastTime -= event.passedTime;
				if (skillObLastTime < 0) {
					isOb = false;
					this.filter = ghostFilter;
				}
			}
			if (isZombie) {
				skillConvertLastTime -= event.passedTime;
				if (skillConvertLastTime < 0) {
					isZombie = false;
					this.filter = ghostFilter;
				}
			}
			//if (frame == 30) {
				//addDeadMessage();
			//}
			
			//trace("ini done");
			if (!overFlag)
				textSpace.myTimer.text = fixTime(frame_real);
			frame_real += event.passedTime;
			sum += event.passedTime;
			if (frame % 10 == 0) {
				var a : int = int(1.0 / sum * 10 * 100);
				if (a % 100 < 10)
					textSpace.fpsText.text = "fps: " + String(int(a / 100)) + ".0" + String(a % 100);
				else
					textSpace.fpsText.text = "fps: " + String(int(a / 100)) + "." + String(a % 100);
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
				times = 2;
				if (isZombie) times = times + 1;
				else if (isGhost) times += 2;
				/*myFilter.centerX += dx * 5;
				myFilter.centerY += dy * 5;
				player_icon.x += dx * 5;
				player_icon.y += dy * 5;*/
			} else {
				times = 1;
				/*myFilter.centerX += dx * 3;
				myFilter.centerY += dy * 3;
				player_icon.x += dx * 3;
				player_icon.y += dy * 3;*/
			}
			if (isOb) times = 0;
			for (var i : int = 0; i < times; i++) {
				var tx : int = (player_icon.x - 30) / 9;
				var ty : int = (player_icon.y - 15) / 9;
				var flag : int = 1;
				//trace("! " + tx + " " + ty);
				if (!isGhost || isZombie)
				for (var xx : int = -1; xx <= 1; xx++)
					for (var yy : int = -1; yy <= 1; yy++)
						if (maze._mazeMap[tx + xx][ty + yy])
							if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x + dx, player_icon.x + 4 + dx)
								&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y, player_icon.y + 4))
								flag = 0;
				//flag = 1;
				if (flag == 1) player_icon.x += dx;
				
				flag = 1;
				if (!isGhost || isZombie)
				for (var xx : int = -1; xx <= 1; xx++)
					for (var yy : int = -1; yy <= 1; yy++)
						if (maze._mazeMap[tx + xx][ty + yy])
							if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x, player_icon.x + 4)
								&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y + dy, player_icon.y + 4 + dy))
								flag = 0;
				//flag = 1;
				if (flag == 1) player_icon.y += dy;
			}
			if (overFlag)
				isZombie = false;
			if (isGhost) {
				player_icon.x = Math.max(player_icon.x, 30 + 9);
				player_icon.x = Math.min(player_icon.x, 30 + limitx * 9 - 9);
				player_icon.y = Math.max(player_icon.y, 15 + 9);
				player_icon.y = Math.min(player_icon.y, 15 + limity * 9 - 9);
			}
			if (myFilter != null) {
				myFilter.x = player_icon.x;
				myFilter.y = player_icon.y;
				if (isGhost) {
					ghostFilter.x = player_icon.x;
					ghostFilter.y = player_icon.y;
					zombieFilter.x = player_icon.x;
					zombieFilter.y = player_icon.y;
					obFilter.x = player_icon.x;
					obFilter.y = player_icon.y;
				}
			}
			textSpace.playerNameText.x = player_icon.x - 50;
			textSpace.playerNameText.y = player_icon.y - 30;
			if (!overFlag && !isGhost) {
				if (check(30 + ex * 9, 30 + ex * 9 + 9, player_icon.x, player_icon.x + 4)
					&& check(15 + ey * 9, 15 + ey * 9 + 9, player_icon.y, player_icon.y + 4)) {
					overFlag = true;
					mySocket.sendWinMessage(playerId, player_icon.x, player_icon.y, playerName, isGhost, isZombie, inRoom, alive, seed, ping);
				}
			}
			textSpace.addUser(playerId, playerName, alive, isGhost, ping);
			/*trace(players.length);
			for (var j : int = 0; j < players.length; j++)
				if (players[j].id == playerId) {
					players[j].x = player_icon.x;
					players[j].y = player_icon.y;
					players[j].isGhost = isGhost;
					players[j].isZombie = isZombie;
					players[j].name = playerName;
					players[j].alive = alive;
					players[j].room = inRoom;
					players[j].seed = seed;
					players[j].ping = ping;
					apprflag = true;
					trace("haha");
					break;
				}*/
			if (networkUse) {
				mySocket.sendMessage(playerId, player_icon.x, player_icon.y, playerName, isGhost, isZombie, inRoom, alive, seed, ping);
				for (var i : int = 0; i < mySocket.players.length; i++) {
					if (mySocket.players[i].id == playerId)
						continue;
					var apprflag : Boolean = false; 
					for (var j : int = 0; j < players.length; j++) {
						if (mySocket.players[i].id == players[j].id) {
							players[j].x = mySocket.players[i].x;
							players[j].y = mySocket.players[i].y;
							players[j].isGhost = mySocket.players[i].isGhost;
							players[j].isZombie = mySocket.players[i].isZombie;
							players[j].name = mySocket.players[i].name;
							players[j].alive = mySocket.players[i].alive;
							players[j].room = mySocket.players[i].room;
							players[j].seed = mySocket.players[i].seed;
							players[j].ping = mySocket.players[i].ping;
							
							apprflag = true;
							break;
						}
					}
					if (!apprflag) {
						textSpace.addUser(mySocket.players[i].id, mySocket.players[i].name, mySocket.players[i].alive, mySocket.players[i].isGhost, mySocket.players[i].ping);
						players.push(new PlayerInfo(mySocket.players[i].id, mySocket.players[i].x, mySocket.players[i].y, mySocket.players[i].name, mySocket.players[i].isGhost, 
							mySocket.players[i].isZombie, mySocket.players[i].alive, mySocket.players[i].room, mySocket.players[i].seed, mySocket.players[i].ping));
						displayed.push(false);
					} else textSpace.addUser(mySocket.players[i].id, mySocket.players[i].name, mySocket.players[i].alive, mySocket.players[i].isGhost, mySocket.players[i].ping);
				}
				for (var i : int = 0; i < players.length; i++) {
					var canSee : Boolean = true;
					var zombieDel : int = 0;
					if (isZombie)
						zombieDel = 900;
					if (isOb)
						zombieDel = -900;
					if (playerType == 1)
						zombieDel = -900;
					if (playerType == 2 && players[i].isGhost)
						zombieDel = -2000;
					canSee = (canSee && ((sqr(players[i].x - player_icon.x) + sqr(players[i].y - player_icon.y) <= 1623 - zombieDel) || playerType == 0 && !players[i].isGhost));
					/*trace("???" + sqr(players[i].x - player_icon.x) + sqr(players[i].y - player_icon.y));
					if (canSee)
						trace("canSee1 !!!!");*/
					canSee = (canSee && (!players[i].isGhost || players[i].isZombie || playerType == 2));
					//if (canSee)
//						trace("canSee2 !!!!");
					canSee = (canSee && (!(isGhost && !isZombie) || isOb));
					canSee = (canSee || this.filter == null || isGhost && players[i].isGhost);
					canSee = (canSee && players[i].alive);
					if (displayed[i]) {
						if (canSee) {
							movePlayer(players[i].id, players[i].x, players[i].y, players[i].isGhost && !players[i].isZombie);
							displayed[i] = true;
						} else {
							displayed[i] = false;
							erasePlayer(players[i].id);
						}
					} else {
						if (canSee) {
							drawPlayer(players[i].id, players[i].x, players[i].y, players[i].name, players[i].isGhost, players[i].isGhost && !players[i].isZombie);
							displayed[i] = true;
						} else {
							displayed[i] = false;
						}
					}
				}
					/*if (displayed[i]) {
						if (isGhost && !isZombie || sqr(players[i].x - player_icon.x) + sqr(players[i].y - player_icon.y) > 2500 && this.filter != null
						) {
							displayed[i] = false;
							erasePlayer(players[i].id);
						} else {
							movePlayer(players[i].id, players[i].x, players[i].y);
							displayed[i] = true;
						}
					} else { 
						if (((!isGhost || isZombie) && sqr(players[i].x - player_icon.x) + sqr(players[i].y - player_icon.y) <= 2500 || this.filter == null)
						&& (!players[i].isGhost || players[i].isZombie)) {
							drawPlayer(players[i].id, players[i].x, players[i].y, players[i].name);
							displayed[i] = true;
						} else displayed[i] = false;
					}*/
			}
		}
		public function dropMessage() : void
		{
			//trace("droped " + mySocket);
			if (networkUse)
				mySocket.dropMessage(playerId, player_icon.x, player_icon.y, playerName, isGhost, isZombie, inRoom, alive, seed, ping);
			//trace("droped " + mySocket);
		}
		public function sqr(a : Number) : int
		{
			return a * a;
		}
		public function drawPlayer (_id : int, _x : int, _y : int, _name : String, _ig : Boolean, _sp : Boolean) : void
		{
			var newPlayerImage : PlayerImage = new PlayerImage(_id, _x, _y, _name, _ig, _sp);
			textSpace.addChild(newPlayerImage.nameField);
			addChild(newPlayerImage.playerImage);
			playersImages.push(newPlayerImage);
		}
		public function movePlayer (_id : int, _x : int, _y : int, _sp : Boolean) : void
		{
			for (var i : int = 0; i < playersImages.length; i++)
				if (playersImages[i].id == _id) {
					if (_sp && playersImages[i].nameField.color != Color.PURPLE) {
						playersImages[i].nameField.color = Color.PURPLE;
					} else if (!_sp && playersImages[i].nameField.color == Color.PURPLE) {
						playersImages[i].nameField.color = Color.RED;
					}
					playersImages[i].playerImage.x = _x;
					playersImages[i].playerImage.y = _y;
					playersImages[i].nameField.x = playersImages[i].playerImage.x - 50;
					playersImages[i].nameField.y = playersImages[i].playerImage.y - 30;
					break;
				}
		}
		public function erasePlayer(removeId : int) : void
		{
			for (var i : int = 0; i < playersImages.length; i++)
				if (playersImages[i].id == removeId) {
					textSpace.removeChild(playersImages[i].nameField);
					this.removeChild(playersImages[i].playerImage);
					playersImages[i] = playersImages[playersImages.length - 1];
					playersImages.pop();
					break;
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
			} else if (e.keyCode == 88) { // x
				/*if (isZombie)
					this.filter = zombieFilter;
				else if (isGhost)
					this.filter = ghostFilter;
				else 
					this.filter = myFilter;*/
			} else if (e.keyCode == 9) { // tab
				if (showBoard) {
					showBoard = false;
					textSpace.removeUserBoard();
					textSpace.removeChild(textSpace.userBoard);
				}
			} else if (e.keyCode == 16) { // shift
				plane_rush_flag = true;
			} else if (e.keyCode == 69) { // e
				/*if (isGhost)
					this.filter = ghostFilter;
				else if (isZombie)
					this.filter = zombieFilter;
				else
					this.filter = myFilter;*/
			}
		}
		public var lastUpdate = -1;
		public var headC = 1;
		public var debugC = 1;
		private function onKeyDownHandle(e:KeyboardEvent):void 
		{
		    if (e.keyCode == 13) { // enter
				if (textSpace.inputChar.text != "") {
					if (director.networkUse)
						director.mySocket.sendGameChatMessage(textSpace.inputChar.text, playerName);
					textSpace.inputChar.text = "";
				}
			} else if (e.keyCode == 9) { // tab
				if (!showBoard) {
					showBoard = true;
					textSpace.addChild(textSpace.userBoard);
					textSpace.addUserBoard();
					trace("!!");
				}
			}
			//if (isOb && e.keyCode != 88)
				//return;
			if (deadFlag)
				return;
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
			} else if (e.keyCode == 88) { // x
				//this.filter = null;
				trace("?" + isOb + " " + skillObLastTime);
				if (isGhost && !isZombie && !isOb) {
					var tx : int = (player_icon.x - 30) / 9;
					var ty : int = (player_icon.y - 15) / 9;
					var mini : Number = 1000000000;
					var bx : int = -1;
					var by : int;
					for (var xx : int = -1; xx <= 1; xx++)
						for (var yy : int = -1; yy <= 1; yy++)
							if (maze._mazeMap[tx + xx][ty + yy])
								if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x, player_icon.x + 4)
									&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y, player_icon.y + 4)) {
									var tmp : Number = sqr(30 + (tx + xx) * 9 + 4.5 - (player_icon.x + 2)) + sqr(15 + (ty + yy) * 9 + 4.5 - (player_icon.y + 2));
									if (tmp < mini) {
										mini = tmp;
										bx = tx + xx;
										by = ty + yy;
									}
								}
					if (bx != -1 && trapSpace.isObWall(bx, by) && skillObCd <= 0) {
						skillObCd = 5;
						skillObLastTime = 3;
						this.filter = obFilter;
						isOb = true;
						//trace("YES");
					}
				} else if (isOb && skillObLastTime < 2.5) {
					skillObLastTime = 0;
					trace("done!");
				}
			} else if (e.keyCode == 67) { // c
				if (isGhost && skillTrap > 0) {
					var tx : int = (player_icon.x - 30) / 9;
					var ty : int = (player_icon.y - 15) / 9;
					var mini : Number = 1000000000;
					var bx : int = -1;
					var by : int;
					for (var xx : int = -1; xx <= 1; xx++)
						for (var yy : int = -1; yy <= 1; yy++)
							if (!maze._mazeMap[tx + xx][ty + yy])
								if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x, player_icon.x + 4)
									&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y, player_icon.y + 4)) {
									var tmp : Number = sqr(30 + (tx + xx) * 9 + 4.5 - (player_icon.x + 2)) + sqr(15 + (ty + yy) * 9 + 4.5 - (player_icon.y + 2));
									if (tmp < mini) {
										mini = tmp;
										bx = 30 + (tx + xx) * 9;
										by = 15 + (ty + yy) * 9;
									}
								}
					if (bx != -1 && !trapSpace.trapped(bx, by)) {
						skillTrap--;
						trapSpace.addTrap(bx, by);
						if (networkUse)
							mySocket.sendTrapMessage(playerId, bx, by);
					}
				}
			} else if (e.keyCode == 65) { // a
				if (isGhost) {
					var tx : int = (player_icon.x - 30) / 9;
					var ty : int = (player_icon.y - 15) / 9;
					var mini : Number = 1000000000;
					var bx : int = -1;
					var by : int;
					for (var xx : int = -1; xx <= 1; xx++)
						for (var yy : int = -1; yy <= 1; yy++)
							if (!maze._mazeMap[tx + xx][ty + yy])
								if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x, player_icon.x + 4)
									&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y, player_icon.y + 4)) {
									var tmp : Number = sqr(30 + (tx + xx) * 9 + 4.5 - (player_icon.x + 2)) + sqr(15 + (ty + yy) * 9 + 4.5 - (player_icon.y + 2));
									if (tmp < mini) {
										mini = tmp;
										bx = 30 + (tx + xx) * 9;
										by = 15 + (ty + yy) * 9;
									}
								}
					//trace("pos " + bx + " " + by);
					if (bx != -1 && trapSpace.trapped(bx, by)) {
						actTrap(bx, by);
					}
				}
			} else if (e.keyCode == 69) { // e
				//this.filter = null;
				//headC++;
				//textSpace.removeUser(headC);
			} else if (e.keyCode == 68) { // d
				//debugC++;
				//textSpace.addUser(debugC, String(debugC), debugC % 2 == 0, debugC % 2 == 1, debugC % 2); 
				//gameOver("Human escaped!");
				  //gameOver("Ghost success!");
				/*if (isGhost) {
					var tx : int = (player_icon.x - 30) / 9;
					var ty : int = (player_icon.y - 15) / 9;
					var mini : Number = 1000000000;
					var bx : int = -1;
					var by : int;
					for (var xx : int = -1; xx <= 1; xx++)
						for (var yy : int = -1; yy <= 1; yy++)
							if (!maze._mazeMap[tx + xx][ty + yy])
								if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x, player_icon.x + 4)
									&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y, player_icon.y + 4)) {
									var tmp : Number = sqr(30 + (tx + xx) * 9 + 4.5 - (player_icon.x + 2)) + sqr(15 + (ty + yy) * 9 + 4.5 - (player_icon.y + 2));
									if (tmp < mini) {
										mini = tmp;
										bx = 30 + (tx + xx) * 9;
										by = 15 + (ty + yy) * 9;
									}
								}
					//trace("pos " + bx + " " + by);
					if (bx != -1)// && trapSpace.trapped(bx, by)) {
						deadGrid(bx, by);
				}*/
			} else if (e.keyCode == 90) { // z
				if (playerType == 0) {
/*					if (skillSeeCd <= 0) {
						isSee = true;
						skillSeeCd = 15;
						skillSeeLast = 5;
					}*/
				} else if (isGhost && !isZombie && skillConvertCd <= 0.0001 && !isOb) {
					var inseFlag : Boolean = false;
					var tx : int = (player_icon.x - 30) / 9;
					var ty : int = (player_icon.y - 15) / 9;
					for (var xx : int = -1; xx <= 1; xx++)
						for (var yy : int = -1; yy <= 1; yy++)
							if (maze._mazeMap[tx + xx][ty + yy])
								if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x, player_icon.x + 4)
									&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y, player_icon.y + 4)) {
									inseFlag = true;
								}
					if (inseFlag) {
						var mini : Number = 1000000000;
						var bx : int = -1;
						var by : int;
						for (var xx : int = -1; xx <= 1; xx++)
							for (var yy : int = -1; yy <= 1; yy++)
								if (!maze._mazeMap[tx + xx][ty + yy])
									if (check(30 + (tx + xx) * 9, 30 + (tx + xx) * 9 + 9, player_icon.x, player_icon.x + 4)
										&& check(15 + (ty + yy) * 9, 15 + (ty + yy) * 9 + 9, player_icon.y, player_icon.y + 4)) {
										var tmp : Number = sqr(30 + (tx + xx) * 9 + 4.5 - (player_icon.x + 2)) + sqr(15 + (ty + yy) * 9 + 4.5 - (player_icon.y + 2));
										if (tmp < mini) {
											mini = tmp;
											bx = 30 + (tx + xx) * 9;
											by = 15 + (ty + yy) * 9;
										}
									}
						if (bx != -1) {
							player_icon.x = bx + 3;
							player_icon.y = by + 3;
							isZombie = true;
							skillConvertCd = 15;
							skillConvertLastTime = 6;
							this.filter = zombieFilter;
						}
					} else {
						isZombie = true;
						skillConvertCd = 15;
						skillConvertLastTime = 6;
						this.filter = zombieFilter;
					}
				} else if (isZombie && skillConvertLastTime < 3) {
					skillConvertLastTime = 0;
				}
			} else if (e.keyCode == 16) { // shift
				plane_rush_flag = false;
			}
		}
		public function getChat(a : String, _name : String) : void
		{
			if (textSpace.charContent.length >= 6) {
				textSpace.charContent.shift();
			}
			textSpace.charContent.push(_name + ": " + a + "\n");
			var tmp : String = "";
			for (var i : int = 0; i < textSpace.charContent.length; i++)
				tmp += textSpace.charContent[i];
			textSpace.charBoard.text = tmp;
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
		
		public var showBoard : Boolean = false;
		
		public var playersImages : Vector.<PlayerImage> = new Vector.<PlayerImage>();
		public var players : Vector.<PlayerInfo>;
		public var displayed : Vector.<Boolean>;
		
		public var mazeImage : Array;
		public var maze : MazeCreater;
		public var frame : int = 0;
		public var ex : int = 0;
		public var ey : int = 0;
		public var frame_real : Number = 0;
		public var overFlag : Boolean = false;
		
		public var bgm : Sound; //bgm音轨
		public var bgm_channel : SoundChannel; //bgm音轨
		public var bgm_voice : SoundTransform; //bgm的音量设置
		public var lighting : Sound;
		public var lightingChannel : SoundChannel;
		public var deadSe : Sound;
		public var deadSeChannel : SoundChannel;
		//public var bgm_voice : SoundTransform;
		
		
		
		public var seed : int = -1;
		public var playerId : int = -1;
		public var playerName : String = "Guest305";
		
		
		public var deadSpace : DeadSpace;
		public var textSpace : TextSpace;
		public var trapSpace : TrapSpace;
		public var light : BlurFilter = BlurFilter.createGlow();
	}
}
