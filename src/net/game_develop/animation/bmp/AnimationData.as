package net.game_develop.animation.bmp 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * 动画数据
	 * @author lizhi http://game-develop.net/
	 */
	public class AnimationData
	{
		/**
		 * 名字
		 */
		public var name:String;
		/**
		 * 所有帧
		 */
		public var frames:Vector.<uint>;
		/**
		 * 所有位图
		 */
		public var bmds:Vector.<BitmapData>;
		/**
		 * 偏移
		 */
		public var offset:Point;
		/**
		 * 宽高
		 */
		public var wh:Point;
		public function AnimationData() 
		{
			
		}
		/**
		 * 刷新宽高
		 */
		public function updateWH():void {
			if (wh == null) wh = new Point;
			for each(var bmd:BitmapData in bmds) {
				wh.x = wh.x < bmd.width?bmd.width:wh.x;
				wh.y = wh.y < bmd.height?bmd.height:wh.y;
			}
		}
	}

}