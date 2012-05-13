package net.game_develop.animation.hittests 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.game_develop.animation.gpu.display.GpuObj2d;
	/**
	 * 基于像素的碰撞检测类
	 * @author lizhi
	 */
	public class FastPixelHittest 
	{
		private var matr:Matrix3D=new Matrix3D;
		private var v3d:Vector3D=new Vector3D;
		private var v3d2:Vector3D;
		
		public function FastPixelHittest() 
		{
			
		}
		public function hittest(mouseX:Number,mouseY:Number,obj2d:GpuObj2d):Boolean {
			var bmd:BitmapData = obj2d.bmd;
			
			if (bmd == null) return false;
			
			matr.rawData = obj2d.wmatrix.rawData;
			matr.appendScale(1, -1, 1);
			matr.invert();
			
			matr.appendTranslation( -obj2d.offsetX, obj2d.offsetY, 0);
			matr.appendScale(bmd.width/obj2d.width, bmd.height/obj2d.height, 1);
			v3d.x = mouseX;
			v3d.y = mouseY;
			v3d2 = matr.transformVector(v3d);
			v3d2.y = -v3d2.y;
			
			if (v3d2.x<0||v3d2.y<0||v3d2.x>=bmd.width||v3d2.y>=bmd.height) {
				return false;
			}
			
			
			var color:uint = bmd.getPixel32(Math.round(v3d2.x), Math.round(v3d2.y))&0xff000000;
			return color > 0;
		}
	}

}