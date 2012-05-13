package net.game_develop.animation.gpu.renders 
{
	import net.game_develop.animation.gpu.display.GpuObj2d;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BasicRenderer implements IRenderer 
	{
		private static var _instance:BasicRenderer;
		public function BasicRenderer() 
		{
			if (_instance) throw "this is a instance class";
		}
		
		/* INTERFACE net.game_develop.animation.gpu.render.IRenderer */
		
		public function render(obj2d:GpuObj2d):void 
		{
			
		}
		
		static public function get instance():BasicRenderer 
		{
			if (_instance == null)_instance = new BasicRenderer;
			return _instance;
		}
		
	}

}