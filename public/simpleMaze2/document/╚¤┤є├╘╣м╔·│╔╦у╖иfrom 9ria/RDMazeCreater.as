package{
	//递归分割法迷宫生成器
	//递归分割法生成的迷宫较为简单，直路多且不扭曲，还可以生成“小房间”，此算法十分高效
	public class RDMazeCreater{
		//随机数种子
		private const MAXRATIO:Number=1/(uint.MAX_VALUE+1);
		private var _seed:uint;
		
		//迷宫参数
		private var _haveBorder:Boolean;
		private var _block:Object;
		private var _noBlock:Object;
		private var _minArea:int;
		
		//迷宫数组
		private var _mazeMap:Array;
		
		//构造函数，用于设置统一的迷宫参数
		//haveBorder外围是否带有一圈边框
		//minArea最小分割面积
		//block不可通行的表示法
		//noBlock可通行的表示法
		public function RDMazeCreater(haveBorder:Boolean=false,minArea:int=4,block:Object=true,noBlock:Object=false){
			_haveBorder=haveBorder;
			_block=block;
			_noBlock=noBlock;
			_minArea=minArea;
		}
		
		//产生迷宫数组
		//mazeWidth迷宫的宽度
		//mazeHeight迷宫的高度
		//seed迷宫种子，默认随机
		//minArea临时最小分割面积
		public function createMaze(mazeWidth:int,mazeHeight:int,seed:uint=0,minArea:int=0):Array{
			//设置随机种子，0就使用时间做种
			_seed=(seed || Math.floor(Math.random()*uint.MAX_VALUE)+1);
			
			//临时最小分割面积
			var tmpMinArea:int=_minArea;
			if(minArea!=0){
				_minArea=minArea;
			}
			
			//将返回的迷宫数组
			_mazeMap=new Array();
			
			//迷宫尺寸合法化
			if(mazeWidth<1)
			mazeWidth=1;
			if(mazeHeight<1)
			mazeHeight=1;
			
			//减去边框占的格子
			if(!_haveBorder){
				mazeWidth--;
				mazeHeight--;
			}
			
			//将迷宫的长宽换算成带墙的尺寸
			mazeWidth*=2;
			mazeHeight*=2;
			
			//产生出空白迷宫
			for(var x:int=0;x<=mazeWidth;x++){
				_mazeMap.push(new Array());
				for(var y:int=0;y<=mazeHeight;y++){
					if(_haveBorder && (x==0 || y==0 || x==mazeWidth || y==mazeHeight)){
						_mazeMap[x].push(_block);
					}else{
						_mazeMap[x].push(_noBlock);
					}
				}
			}
			
			//产生迷宫
			if(_haveBorder){
				recursiveDivision(1,mazeWidth-1,1,mazeHeight-1);
			}else{
				recursiveDivision(0,mazeWidth,0,mazeHeight);
			}
			
			//恢复最小分割面积
			_minArea=tmpMinArea;
			
			//返回生成的迷宫
			return _mazeMap;
		}
		
		//使用递归分割法产生迷宫数组
		//参数为要分割区域的范围
		private function recursiveDivision(left:int,right:int,top:int,bottom:int){
			//检查是否达到了最小分割面积
			if(_minArea>4){
				if((right-left+1)*(bottom-top+1)<_minArea){
					return;
				}
			}
			
			//假设分割点不存在
			var dx:int=-1;
			var dy:int=-1;
			
			//产生随机分割点
			if(right-left>=2){
				dx=left+1+Math.floor(rand()*((right-left)/2))*2;
			}
			if(bottom-top>=2){
				dy=top+1+Math.floor(rand()*((bottom-top)/2))*2;
			}
			
			//没有继续分割的必要
			if(dx==-1 && dy==-1){
				return;
			}
			
			//补上墙壁
			if(dx!=-1){
				for(var y:int=top;y<=bottom;y++){
					_mazeMap[dx][y]=_block;
				}
			}
			if(dy!=-1){
				for(var x:int=left;x<=right;x++){
					_mazeMap[x][dy]=_block;
				}
			}
			
			//为确保连通，随机打通墙壁且不产生环路，并递归分割子区域
			if(dx!=-1 && dy!=-1){
				var side:int=Math.floor(rand()*4);
				if(side!=0){
					_mazeMap[dx][top+Math.floor(rand()*((dy-1-top)/2+1))*2]=_noBlock;
				}
				if(side!=1){
					_mazeMap[dx+1+Math.floor(rand()*((right-dx-1)/2+1))*2][dy]=_noBlock;
				}
				if(side!=2){
					_mazeMap[dx][dy+1+Math.floor(rand()*((bottom-dy-1)/2+1))*2]=_noBlock;
				}
				if(side!=3){
					_mazeMap[left+Math.floor(rand()*((dx-1-left)/2+1))*2][dy]=_noBlock;
				}
				recursiveDivision(left,dx-1,top,dy-1);
				recursiveDivision(dx+1,right,top,dy-1);
				recursiveDivision(dx+1,right,dy+1,bottom);
				recursiveDivision(left,dx-1,dy+1,bottom);
			}else if(dx==-1){
				_mazeMap[left+Math.floor(rand()*((right-left)/2+1))*2][dy]=_noBlock;
				recursiveDivision(left,right,top,dy-1);
				recursiveDivision(left,right,dy+1,bottom);
			}else if(dy==-1){
				_mazeMap[dx][top+Math.floor(rand()*((bottom-top)/2+1))*2]=_noBlock;
				recursiveDivision(left,dx-1,top,bottom);
				recursiveDivision(dx+1,right,top,bottom);
			}
		}
		
		//产生随机数
		private function rand():Number{
			_seed^=(_seed<<21);
			_seed^=(_seed>>>35);
			_seed^=(_seed<<4);
			return _seed*MAXRATIO;
		}
	}
}