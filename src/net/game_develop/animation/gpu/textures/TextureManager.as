package net.game_develop.animation.gpu.textures 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextureManager 
	{
		private static var _instance:TextureManager;
		public var lib:Dictionary = new Dictionary;
		public function TextureManager() 
		{
			if (_instance) throw "this is a instance class";
		}
		
		static public function get instance():TextureManager 
		{
			if (_instance == null)_instance = new TextureManager;
			return _instance;
		}
		
		public function getTexture(bmd:BitmapData, c3d:Context3D):Texture {
			if (bmd == null) return null;
			if (lib[bmd]==null) {
				var w:int = 2048;
				var h:int = 2048;
				for (var i:int = 0; i < 12; i++ ) {
					var pow:int = Math.pow(2, i);
					if (pow>=bmd.width) {
						w = pow;
						break;
					}
				}
				for (i = 0; i < 12; i++ ) {
					pow = Math.pow(2, i);
					if (pow>=bmd.height) {
						h = pow;
						break;
					}
				}
				
				var temp:BitmapData = new BitmapData(w, h, true, 0);
				temp.draw(bmd, new Matrix(w / bmd.width, 0, 0, h / bmd.height), null, null, null, true);
				var texture:Texture = c3d.createTexture(w, h, Context3DTextureFormat.BGRA, false);
				texture.uploadFromBitmapData(temp);
				temp.dispose();
				lib[bmd]=texture
			}
			return lib[bmd];
		}
	}

}