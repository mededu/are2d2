package net.game_develop.animation.gpu.renders 
{
	import flash.display3D.Context3D;
	import net.game_develop.animation.gpu.display.GpuObj2d;
	import net.game_develop.animation.gpu.GpuView2d;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public interface IRenderer 
	{
		function render(obj2d:GpuObj2d, view:GpuView2d):void;
		function initObj2d(obj2d:GpuObj2d, c3d:Context3D):void;
	}
	
}