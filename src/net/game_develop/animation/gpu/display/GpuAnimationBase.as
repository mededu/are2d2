package net.game_develop.animation.gpu.display 
{
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	/**
	 * gpu动画基本
	 * @author lizhi
	 */
	public class GpuAnimationBase 
	{
		private var _selfMatrix:Matrix3D;
		public var vouts:Vector.<Number>;
		public var bmd:BitmapData;
		public var texture:Texture;
		public var uv:Rectangle;
		public var uvvertexBuffer:VertexBuffer3D;
		public function GpuAnimationBase(bmd:BitmapData,matr:Matrix3D=null) 
		{
			this.bmd = bmd;
			selfMatrix = matr;
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