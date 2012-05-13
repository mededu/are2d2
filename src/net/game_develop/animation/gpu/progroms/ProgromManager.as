package net.game_develop.animation.gpu.progroms 
{
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ProgromManager 
	{
		private static var _instance:ProgromManager;
		public function ProgromManager() 
		{
			if (_instance) throw "this is a inatance class";
		}
		
		static public function get instance():ProgromManager 
		{
			if (_instance == null)_instance = new ProgromManager;
			return _instance;
		}
		
		public function getProgrom(vertexCode:String, fragmentCode:String, c3d:Context3D):Program3D {
			return null;
		}
	}

}