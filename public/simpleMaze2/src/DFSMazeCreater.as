package{
	//深度优先法迷宫生成器
	//深度优先法生成的迷宫极度扭曲，有着一条明显的主路
	public class DFSMazeCreater extends MazeCreater{
		//随机数种子
		private const MAXRATIO:Number=1/(uint.MAX_VALUE+1);
		
		//迷宫参数
		private var _haveBorder:Boolean;
		private var _block:Object;
		private var _noBlock:Object;
		
		//存路径的盏
		private var stack:Array=new Array();
		//存周围未连通格坐标的组
		private var blockPos:Array=new Array(8);
		
		//迷宫数组
		
		//构造函数，用于设置统一的迷宫参数
		//haveBorder外围是否带有一圈边框
		//block不可通行的表示法
		//noBlock可通行的表示法
		public function DFSMazeCreater(haveBorder:Boolean=true,block:Object=true,noBlock:Object=false){
			_haveBorder=haveBorder;
			_block=block;
			_noBlock=noBlock;
		}
		
		//产生迷宫数组
		//mazeWidth迷宫的宽度
		//mazeHeight迷宫的高度
		//startX起点X，默认随机（不算边框和墙壁，从0起）
		//startY起点Y，默认随机（不算边框和墙壁，从0起）
		//seed迷宫种子，默认随机
		public function createMaze(mazeWidth:int,mazeHeight:int,startX:int=-1,startY:int=-1,seed:uint=0):Array{
			//设置随机种子，0就使用时间做种
			_seed=(seed || Math.floor(Math.random()*uint.MAX_VALUE)+1);
			
			//将返回的迷宫数组
			_mazeMap=new Array();
			
			//迷宫尺寸合法化
			if(mazeWidth<1)
			mazeWidth=1;
			if(mazeHeight<1)
			mazeHeight=1;
			
			//迷宫起点合法化
			if(startX<0 || startX>=mazeWidth)
				startX=Math.floor(rand()*(mazeWidth - 2)) + 1;
			if(startY<0 || startY>=mazeHeight)
				startY=Math.floor(rand()*(mazeHeight - 2)) + 1;
			
			//减去边框占的格子
			if(!_haveBorder){
				mazeWidth--;
				mazeHeight--;
			}
			
			//将迷宫的长宽换算成带墙的尺寸
			mazeWidth*=2;
			mazeHeight*=2;
			
			//将迷宫的起点换算成带墙的位置
			startX*=2;
			startY*=2;
			if(_haveBorder){
				startX++;
				startY++;
			}
			sx = startX;
			sy = startY;
			ex = -1;
			
			
			//产生出空白迷宫
			for(var x:int=0;x<=mazeWidth;x++){
				_mazeMap.push(new Array());
				for(var y:int=0;y<=mazeHeight;y++){
					_mazeMap[x].push(_block);
				}
			}
			
			//产生迷宫
			depthFirstSearch(startX,startY,mazeWidth-1,mazeHeight-1);
			
			//返回生成的迷宫
			//trace("??" + ex);
			return _mazeMap;
		}
		
		//使用深度优先法产生迷宫数组
		//参数为迷宫（树）带墙的起点位置和长宽限制尺寸
		private function depthFirstSearch(startX:int,startY:int,widthLimit:int,heightLimit:int){
			//周围未标记格的数量
			var blockNum:int=0;
			var maxlen:int=0;
			
			//将起点作为当前格
			var currentX:int=startX;
			var currentY:int=startY;
			
			
			//标记起点
			_mazeMap[currentX][currentY]=_noBlock;
			
			do{
				if (stack.length > maxlen) {
					//trace("!!!!!!!");
					ex = currentX;
					ey = currentY;
					//trace(ex);
					//trace(ey);
					maxlen = stack.length;
				}
				//检测周围有没有未连通的格子
				blockNum=0;
				//检查上方
				if(currentY>1 && _mazeMap[currentX][currentY-2]==_block){
					blockPos[0]=currentX;
					blockPos[1]=currentY-2;
					blockNum++;
				}
				//检查右侧
				if(currentX<widthLimit && _mazeMap[currentX+2][currentY]==_block){
					blockPos[blockNum*2]=currentX+2;
					blockPos[blockNum*2+1]=currentY;
					blockNum++;
				}
				//检查下方
				if(currentY<heightLimit && _mazeMap[currentX][currentY+2]==_block){
					blockPos[blockNum*2]=currentX;
					blockPos[blockNum*2+1]=currentY+2;
					blockNum++;
				}
				//检查左侧
				if(currentX>1 && _mazeMap[currentX-2][currentY]==_block){
					blockPos[blockNum*2]=currentX-2;
					blockPos[blockNum*2+1]=currentY;
					blockNum++;
				}
				
				//选出下一个当前格
				if(blockNum){
					//随机选择一个邻格
					blockNum=Math.floor(rand()*blockNum)*2;
					//把当前格入栈
					stack.push(currentX);
					stack.push(currentY);
					//连通邻格
					if(currentX<blockPos[blockNum]){
						currentX++;
					}else if(currentX>blockPos[blockNum]){
						currentX--;
					}else if(currentY<blockPos[blockNum+1]){
						currentY++;
					}else if(currentY>blockPos[blockNum+1]){
						currentY--;
					}
					_mazeMap[currentX][currentY]=_noBlock;
					//将邻格指定为当前格
					currentX=blockPos[blockNum];
					currentY=blockPos[blockNum+1];
					//标记当前格
					_mazeMap[currentX][currentY]=_noBlock;
				}else if(stack.length){
					//将栈顶作为当前格
					currentY=stack.pop();
					currentX=stack.pop();
				}
			}while(stack.length);
		}
		
	}
}