package net.game_develop.animation.gpu.display 
{
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	/**
	 * gpu动画基本
	 * @author lizhi
	 */
	public class GpuAnimationBase 
	{
		public var uvtexture:UVTexture;
		private var _selfMatrix:Matrix3D;
		public var vouts:Vector.<Number>;
		public var bmd:BitmapData;
		public function GpuAnimationBase(bmd:BitmapData,matr:Matrix3D=null) 
		{
			this.bmd = bmd;
			selfMatrix = matr;
			
			
			if (GpuView2d.viewtool.c3d) {
				uvtexture = GpuView2d.viewtool.getTexture(bmd);
			}else {
				GpuView2d.viewtool.addEventListener(Event.CONTEXT3D_CREATE, viewtool_context3dCreate);
			}
		}
		
		private function viewtool_context3dCreate(e:Event):void 
		{
			uvtexture = GpuView2d.viewtool.getTexture(bmd);
		}
		
		public function get selfMatrix():Matrix3D 
		{
			return _selfMatrix;
		}
		
		public function set selfMatrix(value:Matrix3D):void 
		{
			_selfMatrix = value;
			if (_selfMatrix) {
				vouts = GpuObj2d.getVoutFromSelf(_selfMatrix);
			}
		}
		
	}

}