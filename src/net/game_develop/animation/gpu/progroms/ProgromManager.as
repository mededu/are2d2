package net.game_develop.animation.gpu.progroms 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ProgromManager 
	{
		private static var _instance:ProgromManager;
		private var lib:Array = [];
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
			if (vertexCode == null || fragmentCode == null) return null;
			var code:String = vertexCode + fragmentCode;
			if (lib[code] == null) {
				var vsa:AGALMiniAssembler = new AGALMiniAssembler(false);
				vsa.assemble(Context3DProgramType.VERTEX,
					vertexCode
					);
				var fsa:AGALMiniAssembler = new AGALMiniAssembler(false);
				fsa.assemble(Context3DProgramType.FRAGMENT,
					fragmentCode
					);
				
				var program:Program3D = c3d.createProgram();
				program.upload(vsa.agalcode, fsa.agalcode);
				lib[code] = program;
			}
			return lib[code];
		}
	}

}