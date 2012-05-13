package net.game_develop.animation.gpu.display 
{
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;
	/**
	 * gpu动画动画数据
	 * @author lizhi
	 */
	public class GpuAnimationData 
	{
		public var name:String;
		public var frames:Vector.<uint>;
		public var textures:Vector.<GpuAnimationBase>;
		public function GpuAnimationData() 
		{
			
		}
		
	}

}