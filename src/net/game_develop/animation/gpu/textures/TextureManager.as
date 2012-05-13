package net.game_develop.animation.gpu.textures 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextureManager 
	{
		private static var _instance:TextureManager;
		public function TextureManager() 
		{
			if (_instance == null) throw "this is a instance class";
		}
		
		static public function get instance():TextureManager 
		{
			if (_instance == null)_instance = new TextureManager;
			return _instance;
		}
		
		public function getTexture(bmd:BitmapData, c3d:Context3D):Texture {
			return null;
		}
	}

}