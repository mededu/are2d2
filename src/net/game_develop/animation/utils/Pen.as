package net.game_develop.animation.utils 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import net.game_develop.animation.gpu.GpuObj2d;
	/**
	 * 画笔类
	 * @author lizhi
	 */
	public class Pen 
	{
		private static var penShape:Shape = new Shape;
		public function Pen() 
		{
		}
		
		/**
		 * 画圆
		 * @param	radius
		 * @param	color
		 * @param	alpha
		 * @param	lineThickness
		 * @param	lineColor
		 * @param	lineAlpha
		 * @return
		 */
		public static function createCircle(radius:Number,color:uint,alpha:Number=1,lineThickness:Number=Number.NaN, lineColor:uint=0, lineAlpha:Number=1):GpuObj2d {
			penShape.graphics.clear();
			penShape.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			penShape.graphics.beginFill(color, alpha);
			penShape.graphics.drawCircle(radius, radius, radius-int(lineThickness)/2);
			var bmd:BitmapData = new BitmapData(radius * 2, radius * 2, true, 0);
			bmd.draw(penShape);
			var obj2d:GpuObj2d = new GpuObj2d(radius * 2, radius * 2, bmd, -radius, -radius);
			return obj2d;
		}
		
		/**
		 * 画方
		 * @param	width
		 * @param	height
		 * @param	color
		 * @param	alpha
		 * @param	lineThickness
		 * @param	lineColor
		 * @param	lineAlpha
		 * @return
		 */
		public static function createRect(width:Number, height:Number,color:uint,alpha:Number=1,lineThickness:Number=Number.NaN, lineColor:uint=0, lineAlpha:Number=1):GpuObj2d {
			penShape.graphics.clear();
			penShape.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			penShape.graphics.beginFill(color, alpha);
			penShape.graphics.drawRect(int(lineThickness)/2, int(lineThickness)/2, width-int(lineThickness),height-int(lineThickness));
			var bmd:BitmapData = new BitmapData(width,height, true, 0);
			bmd.draw(penShape);
			var obj2d:GpuObj2d = new GpuObj2d(width,height, bmd, -width/2, -height/2);
			return obj2d;
		}
		
		/**
		 * 从显示对象中得到位图
		 * @param	dis
		 * @return
		 */
		public static function getBmdFromDisplay(dis:DisplayObject):BitmapData {
			var bmd:BitmapData = new BitmapData(dis.width, dis.height, true, 0);
			bmd.draw(dis);
			return bmd;
		}
	}

}