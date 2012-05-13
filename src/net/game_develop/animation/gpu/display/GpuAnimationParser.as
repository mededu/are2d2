package net.game_develop.animation.gpu.display 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import net.game_develop.animation.bmp.AnimationData;
	/**
	 * gpu动画生成器
	 * @author lizhi
	 */
	public class GpuAnimationParser 
	{
		
		public function GpuAnimationParser() 
		{
			
		}
		
		/**
		 * 最基本的生成函数
		 */
		static public function parser(bmds:Vector.<BitmapData>,offsets:Vector.<Point>,name:String):GpuAnimationData {
			var gpu:GpuAnimationData = new GpuAnimationData;
			var frames:Vector.<uint> = new Vector.<uint>;
			gpu.name = name;
			gpu.textures = new Vector.<GpuAnimationBase>;
			for (var i:int = 0; i < bmds.length;i++) {
				frames.push(i);
				var bmd:BitmapData = bmds[i];
				var offset:Point = offsets[i];
				var base:GpuAnimationBase = new GpuAnimationBase(bmd);
				var matr:Matrix3D = new Matrix3D;
				matr.appendTranslation(offset.x / bmd.width, -offset.y /bmd.height, 0);
				matr.appendScale(bmd.width, bmd.height, 1);
				base.selfMatrix = matr;
				gpu.textures.push(base);
			}
			gpu.frames = frames;
			return gpu;
		}
		
		static public function formatToGpu(anm:AnimationData):GpuAnimationData {
			var gpu:GpuAnimationData = new GpuAnimationData;
			gpu.frames = anm.frames;
			gpu.name = anm.name;
			gpu.textures = new Vector.<GpuAnimationBase>;
			for each(var bmd:BitmapData in anm.bmds) {
				var base:GpuAnimationBase = new GpuAnimationBase(bmd);
				var matr:Matrix3D = new Matrix3D;
				matr.appendTranslation(anm.offset.x / bmd.width, -anm.offset.y /bmd.height, 0);
				matr.appendScale(bmd.width, bmd.height, 1);
				base.selfMatrix = matr;
				gpu.textures.push(base);
			}
			return gpu;
		}
	}

}