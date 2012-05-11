package net.game_develop.animation.bmp 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * 尾巴类，可用做飘影效果
	 * @author lizhi
	 */
	public class Tail extends World
	{
		private var sprites:Vector.<BitmapDataSprite> = new Vector.<BitmapDataSprite>;
		private var tailColorTransform:ColorTransform;
		private var tailFilters:Vector.<BitmapFilter>;
		private var p:Point = new Point;
		private var rect:Rectangle;
		private var bmd:BitmapData;
		private var image2:Bitmap
		private var matr:Matrix = new Matrix;
		
		/**
		 * 构造函数
		 * @param	width 宽度
		 * @param	height	高度
		 * @param	colorTransform	颜色转换
		 * @param	filters	滤镜
		 */
		public function Tail(width:int,height:int,colorTransform:ColorTransform,filters:Vector.<BitmapFilter>) 
		{
			tailColorTransform = colorTransform;
			tailFilters = filters;
			rect = new Rectangle(0, 0, width, height);
			bmd = new BitmapData(width, height, true, 0);
			image2 =new Bitmap(bmd);
			addChild(image2);
		}
		override public function add(sprite:BitmapDataSprite, enableMouse:Boolean = false):BitmapDataSprite {
			sprites.push(sprite);
			return sprite;
		}
		override public function update():void {
			for each(var s:BitmapDataSprite in sprites) {
				bmd.draw(s,s.transform.matrix);
			}
			
			for each(var filter:BitmapFilter in  tailFilters){
				bmd.colorTransform(rect, tailColorTransform);
				bmd.applyFilter(bmd, rect, p, filter);
			}
		}
	}

}