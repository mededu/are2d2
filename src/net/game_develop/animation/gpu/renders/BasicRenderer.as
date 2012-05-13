package net.game_develop.animation.gpu.renders 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;
	import net.game_develop.animation.gpu.display.GpuObj2d;
	import net.game_develop.animation.gpu.GpuView2d;
	import net.game_develop.animation.gpu.progroms.ProgromManager;
	import net.game_develop.animation.gpu.textures.TextureManager;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BasicRenderer implements IRenderer 
	{
		private static var _instance:BasicRenderer;
		private var ibufLib:Dictionary = new Dictionary;
		private var vbufLib:Dictionary = new Dictionary;
		private var defUVBuff:VertexBuffer3D;
		public function BasicRenderer() 
		{
			if (_instance) throw "this is a instance class";
		}
		
		/* INTERFACE net.game_develop.animation.gpu.render.IRenderer */
		
		public function render(obj2d:GpuObj2d,view:GpuView2d):void 
		{
			var c3d:Context3D = view.c3d;
			if (obj2d.change) {
				obj2d.recompose();
			}
			obj2d.wmatrix.rawData = obj2d.vmatrix.rawData;
			if (obj2d.parent) {
				obj2d.wmatrix.append(obj2d.parent.wmatrix);
			}
			//obj2d.update();
			if (!obj2d.inited) {
				initObj2d(obj2d, c3d);
			}
			
			if (obj2d.texture) {
				c3d.setBlendFactors(obj2d.blendSourceFactor, obj2d.blendDestinationFactor);
				
				c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, obj2d.selfMatrix, true);
				c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, obj2d.wmatrix, true);
				c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, view.cammatrix, true);
				
				c3d.setTextureAt(0, obj2d.texture);
				c3d.setProgram(obj2d.program);
				c3d.setVertexBufferAt(0, obj2d.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
				c3d.setVertexBufferAt(1, obj2d.uvvertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				c3d.drawTriangles(obj2d.indexBuffer);
				c3d.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
				c3d.setVertexBufferAt(1, null, 0, Context3DVertexBufferFormat.FLOAT_2);
			}
			if (obj2d.childs) {
				for each(var ob:GpuObj2d in obj2d.childs) {
					ob.renderer.render(ob,view);
				}
			}
		}
		
		public function initObj2d(obj2d:GpuObj2d, c3d:Context3D):void {
			obj2d.inited = true;
			var ibuf:IndexBuffer3D = ibufLib[obj2d.indexData];
			if (ibuf == null) {
				ibuf = c3d.createIndexBuffer(obj2d.indexData.length);
				ibuf.uploadFromVector(obj2d.indexData, 0, obj2d.indexData.length);
				ibufLib[obj2d.indexData] = ibuf;
			}
			obj2d.indexBuffer = ibuf;
			var vbuf:VertexBuffer3D = vbufLib[obj2d.vertexData];
			if (vbuf == null) {
				vbuf = c3d.createVertexBuffer(obj2d.vertexData.length / 3, 3);
				vbuf.uploadFromVector(obj2d.vertexData, 0, obj2d.vertexData.length / 3);
				vbufLib[obj2d.vertexData] = vbuf;
			}
			obj2d.vertexBuffer = vbuf;
			if (obj2d.uv == null) {
				if (defUVBuff == null) {
					defUVBuff = c3d.createVertexBuffer(4, 2);
					defUVBuff.uploadFromVector(Vector.<Number>([0, 0, 1, 0, 0, 1, 1, 1]), 0, 4);
				}
				obj2d.uvvertexBuffer = defUVBuff;
			}else {
				obj2d.uvvertexBuffer = c3d.createVertexBuffer(4, 2);
				obj2d.uvvertexBuffer.uploadFromVector(Vector.<Number>([obj2d.uv.left, obj2d.uv.top, obj2d.uv.right, obj2d.uv.top,
				obj2d.uv.left, obj2d.uv.bottom, obj2d.uv.right, obj2d.uv.bottom]), 0, 4);
			}
			obj2d.program = ProgromManager.instance.getProgrom(obj2d.vertexCode, obj2d.fragmentCode, c3d);
			obj2d.texture = TextureManager.instance.getTexture(obj2d.bmd, c3d);
		}
		
		static public function get instance():BasicRenderer 
		{
			if (_instance == null)_instance = new BasicRenderer;
			return _instance;
		}
		
	}

}