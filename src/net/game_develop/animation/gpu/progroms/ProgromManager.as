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
			var code:String = vertexCode + fragmentCode;
			if (lib[code] == null) {
				var vsa:AGALMiniAssembler = new AGALMiniAssembler(false);
				vsa.assemble(Context3DProgramType.VERTEX,
					"m44 vt0,va0,vc0\n"+
					"m44 vt0,vt0,vc4\n"+
					"m44 op,vt0,vc8\n"+
					"mov v0,va1"
					);
				var fsa:AGALMiniAssembler = new AGALMiniAssembler(false);
				fsa.assemble(Context3DProgramType.FRAGMENT,
					"tex ft0, v0, fs0 <2d,linear,nomip>\nmov oc,ft0"
					);
				
				var program:Program3D = c3d.createProgram();
				program.upload(vsa.agalcode, fsa.agalcode);
				lib[code] = program;
			}
			return lib[code];
		}
	}

}