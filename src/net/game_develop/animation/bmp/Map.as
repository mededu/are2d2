package net.game_develop.animation.bmp 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	/**
	 * 高速地图渲染类
	 * @author lizhi http://game-develop.net/
	 */
	public class Map extends Sprite
	{
		public var mapBmd:BitmapData;
		//public var view:Bitmap;
		private var _viewport:Rectangle;
		//private var viewbmd:BitmapData;
		//private var viewRect:Rectangle;
		private var matr:Matrix = new Matrix;
		public var change:Boolean = true;
		/**
		 * 构造函数
		 * @param	width	地图宽度
		 * @param	height	地图高度
		 */
		public function Map(width:int,height:int) 
		{
			//viewbmd = new BitmapData(width, height, false, 0);
			//view = new Bitmap(viewbmd);
			_viewport = new Rectangle(0, 0, width, height);
			//viewRect = viewport.clone();
			//addChild(view);
			
			//view.bitmapData = mapBmd;
			//cacheAsBitmap = true;
		}
		
		/**
		 * 刷新
		 */
		public function update():void {
			
			//fps 42 cpu 50%
			//cacheAsBitmap = true; fps 35 cpu 53%
			//var by:ByteArray = mapBmd.getPixels(viewport);
			//by.position = 0;
			//viewbmd.setPixels(viewRect, by);
			
			//fps 60 cpu 32%
			//cacheAsBitmap = true; fps 60 cpu 57%
			//viewbmd.setVector(viewRect, mapBmd.getVector(viewport));
			
			//fps 58 cpu 50%
			//cacheAsBitmap = true; fps 44 cpu 59%
			//viewbmd.copyChannel(mapBmd, viewport, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			//viewbmd.copyChannel(mapBmd, viewport, new Point(), BitmapDataChannel.RED, BitmapDataChannel.RED);
			//viewbmd.copyChannel(mapBmd, viewport, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			
			//fps 60 cpu 12%
			//cacheAsBitmap = true; fps 60 cpu 33%
			
			if(change){
				graphics.clear();
				matr.tx = -viewport.x;
				matr.ty = -viewport.y;
				graphics.beginBitmapFill(mapBmd,matr,false,false);
				graphics.drawRect(0, 0, viewport.width, viewport.height);
				graphics.endFill();
				change = false;
			}
			
			//fps 60 cpu 12%
			//cacheAsBitmap = true; fps 60 cpu 38%
			//view.bitmapData = mapBmd;
			//view.x = -viewport.x;
			//view.y = -viewRect.y;
		}
		
		/**
		 * 视口大小
		 */
		public function get viewport():Rectangle 
		{
			return _viewport.clone();
		}
		
		public function set viewport(value:Rectangle):void 
		{
			if (!_viewport.equals(value)) {
				change = true;
			}
			_viewport = value;
		}
	}

}