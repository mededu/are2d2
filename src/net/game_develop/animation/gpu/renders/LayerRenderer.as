package net.game_develop.animation.gpu.renders 
{
	import flash.display3D.Context3D;
	import net.game_develop.animation.gpu.GpuView2d;
	import net.game_develop.animation.gpu.display.GpuObj2d;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LayerRenderer  implements IRenderer 
	{
		private static var _instance:LayerRenderer;
		public function LayerRenderer() 
		{
			if (_instance) throw "this is a instance class";
		}
		
		/* INTERFACE net.game_develop.animation.gpu.renders.IRenderer */
		
		public function render(obj2d:GpuObj2d, view:GpuView2d):void 
		{
			obj2d.update();
		}
		
		public function initObj2d(obj2d:GpuObj2d, c3d:Context3D):void 
		{
			
		}
		
		static public function get instance():LayerRenderer 
		{
			if (_instance == null)_instance = new LayerRenderer;
			return _instance;
		}
		
	}

}