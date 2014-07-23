package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	
	[SWF(width="1350", height="630", frameRate="30", backgroundColor="#666666")]
	public class Game extends Sprite
	{
		private var mStarling:Starling;
		
		public function Game() : void
		{
			//stage.quality = "low";
			//stage.alpha = 0.999;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.displayState = "fullScreen";
			stage.align = StageAlign.TOP;
			setTimeout(startApp, 100);
		}
		public function startApp() : void
		{
			mStarling = new Starling(Director, stage);
			mStarling.antiAliasing = 1;
			mStarling.start();
		}
	}
}