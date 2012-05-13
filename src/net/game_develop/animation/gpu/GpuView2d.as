package net.game_develop.animation.gpu 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import net.game_develop.animation.gpu.display.GpuObj2d;
	import net.game_develop.animation.hittests.FastPixelHittest;
	import net.game_develop.animation.utils.ARE2D;
	/**
	 * gpu动画的显示容器，可以定义视口的大小，控制视口的位置等功能。
	 * @author lizhi
	 */
	public class GpuView2d extends Sprite
	{
		/**
		 * 一个GpuView2d静态实例
		 */
		///public static var viewtool:GpuView2d;
		/**
		 * stage3d
		 */
		public var stage3d:Stage3D;
		/**
		 * context3d
		 */
		public var c3d:Context3D;
		//private var ibuf:IndexBuffer3D;
		//private var obj2ds:Array = [];
		/**
		 * 显示对象root
		 */
		public var _root:GpuObj2d;
		private var _viewWidth:Number;
		private var _viewHeight:Number;
		//private var textureLib:Dictionary = new Dictionary;
		/**
		 * texture库
		 */
		//public var textures:Array = [];
		//private var nowTextureId:int = 0;
		//private var vsa:AGALMiniAssembler;
		//private var programLib:Array = [];//0 1colormul 2coloradd 3colormul+coloradd 4layer
		private var _ihittest:FastPixelHittest;
		private var nowMouseObjs:Array = [];
		private var currentMouseObjs:Array;
		/**
		 * 摄像机矩阵，可以控制摄像机的位置
		 */
		public var cammatrix:Matrix3D;
		/**
		 * 顶点buff
		 */
		//public var vbuf:VertexBuffer3D;
		
		/**
		 * 
		 * @param	vwidth	视口的宽度
		 * @param	vheight	视口的高度
		 */
		public function GpuView2d(vwidth:Number,vheight:Number) 
		{
			//viewtool = this;
			_root = new GpuObj2d(1, 1, null);
			//obj2ds.push(_root);
			//_root.view = this;
			_viewWidth = vwidth;
			_viewHeight = vheight;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage3d = stage.stage3Ds[0];
			stage3d.addEventListener(Event.CONTEXT3D_CREATE, stage3Ds_context3dCreate);
			stage3d.requestContext3D();
			
			
			ARE2D.addMenu(this);
			
		}
		
		
		
		private var _antiAlias:int=0;
		private function stage3Ds_context3dCreate(e:Event):void 
		{
			c3d = stage3d.context3D;
			if (c3d == null) return;
			
			c3d.configureBackBuffer(viewWidth, viewHeight, antiAlias, false);
			//c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			stage3d.x = x;
			stage3d.y = y;
			
			trace(ARE2D.name, c3d.driverInfo);
			ARE2D.renderMode = c3d.driverInfo;
			
			//vbuf = c3d.createVertexBuffer(4, 3);
			//var vdata:Vector.<Number> = Vector.<Number>(
			//	[
			//	0, 0, 0,/* 0,0,*/
			//	1, 0, 0, /*1, 0,*/
			//	0, -1, 0, /*0, 1, */
			//	1,-1,0/*,1,1*/
			//	]);
			//vbuf.uploadFromVector(vdata, 0, 4);
			//c3d.setVertexBufferAt(0, vbuf, 0, Context3DVertexBufferFormat.FLOAT_3);
			//c3d.setVertexBufferAt(1, vbuf, 3, Context3DVertexBufferFormat.FLOAT_2);
			
			//vsa = new AGALMiniAssembler(false);
			//vsa.assemble(Context3DProgramType.VERTEX,
			//	"m44 vt0,va0,vc0\n"+
			//	"m44 vt0,vt0,vc4\n"+
			//	"m44 op,vt0,vc8\n"+
				
				/*"dp4 vt0.x,va0,vc0\n" +
				"dp4 vt0.y,va0,vc1\n" +
				"mov vt0.zw,va0\n"+
				
				"dp4 vt1.x,vt0,vc4\n" +
				"dp4 vt1.y,vt0,vc5\n" +
				"mov vt1.zw,va0\n"+
				
				"dp4 op.x,vt1,vc8\n" +
				"dp4 op.y,vt1,vc9\n"+
				"mov op.zw,va0.zw\n"+*/
				
				//"mov op,vt0\n" +
			//	"mov v0,va1"
			//	);
				
			
			//c3d.setProgram(program);
			//ibuf = c3d.createIndexBuffer(6);
			//var idata:Vector.<uint> = Vector.<uint>([0, 1, 3,3,2,0]);
			//ibuf.uploadFromVector(idata, 0, 6);
			
			cammatrix = new Matrix3D;
			cammatrix.appendScale(2 / viewWidth, 2 / viewHeight, 1);
			cammatrix.appendTranslation( -1, 1, 0);
			
			//c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8,cammatrix , true);
			start();
			
			dispatchEvent(e.clone());
		}
		
		/**
		 * 得到program3d根据颜色转化矩阵
		 * @param	colorTransform
		 * @return
		 */
		/*public function getProgram(colorTransform:ColorTransform):Program3D {
			var id:int = 0;
			if (colorTransform) {
				var isColorMul:Boolean = colorTransform.alphaMultiplier != 1 || colorTransform.redMultiplier != 1 || colorTransform.greenMultiplier != 1 || colorTransform.blueMultiplier != 1;
				var isColorAdd:Boolean = colorTransform.alphaOffset != 0 || colorTransform.redOffset != 0 || colorTransform.greenOffset != 0 || colorTransform.blueOffset != 0;
				
				if (isColorMul) {
					id |= 1;
				}
				if (isColorAdd) {
					id |= 2;
				}
			}
			var program:Program3D = programLib[id];
			if(program==null){
				var code:String = "tex ft0, v0, fs0 <2d,linear,nomip>\n";
				if(isColorMul)code += "mul ft0,ft0,fc0\n";
				if (isColorAdd)  {
					code += "add ft0,ft0,fc1\nmov oc,ft0";
				}else {
					code += "mov oc,ft0";
				}
				
				
				var fsa:AGALMiniAssembler = new AGALMiniAssembler(false);
				fsa.assemble(Context3DProgramType.FRAGMENT,
					code
					);
				
				program = c3d.createProgram();
				program.upload(vsa.agalcode, fsa.agalcode);
				programLib[id] = program;
			}
			return program;
		}*/
		
		/**
		 * 得到gpuspritelayer的program3d
		 * @return
		 */
		/*public function getLayerProgram():Program3D {
			var id:int = 4;
			var program:Program3D = programLib[id];
			if (program == null) {
				
				
				var vsa:AGALMiniAssembler = new AGALMiniAssembler(false);
				vsa.assemble(Context3DProgramType.VERTEX,
					"mov op,va0\n" +
					"mov v0,va1"
					);
				
				var fsa:AGALMiniAssembler = new AGALMiniAssembler(false);
				fsa.assemble(Context3DProgramType.FRAGMENT,
					"tex ft0, v0, fs0 <2d,linear,nomip>\n"+
					"mov oc,ft0"
					);
				
				program = c3d.createProgram();
				program.upload(vsa.agalcode, fsa.agalcode);
				
				programLib[id] = program;
			}
			return program;
			
		}*/
		
		/**
		 * 开始
		 */
		public function start():void {
			addEventListener(Event.ENTER_FRAME, render);
		}
		
		/**
		 * 停止
		 */
		public function stop():void {
			removeEventListener(Event.ENTER_FRAME, render);
		}
		
		/**
		 * 背景颜色 red
		 */
		public var clearR:Number = 1;
		/**
		 * 背景颜色green
		 */
		public var clearG:Number = 1;
		/**
		 * 背景颜色blud
		 */
		public var clearB:Number = 1;
		/**
		 * 背景颜色透明度
		 */
		public var clearA:Number = 0;
		/**
		 * 渲染
		 * @param	e
		 */
		public function render(e:Event = null):void {
			if (c3d == null) return;
			c3d.clear(clearR,clearG,clearB,clearA);
			//for each(var obj2d:GpuObj2d in obj2ds) {
				//doobj(_root);
			//}
			_root.renderer.render(_root,this);
			c3d.present();
			
			/*if (ihittest) {
				currentMouseObjs = [];
				exehittest(obj2ds);
				for each(obj2d in nowMouseObjs) {
					if (currentMouseObjs.indexOf(obj2d)==-1) {
						//mouse_out
						var me:MouseEvent = new MouseEvent(MouseEvent.MOUSE_OUT);
						obj2d.dispatchEvent(me);
					}
				}
				for each(obj2d in currentMouseObjs) {
					if (nowMouseObjs.indexOf(obj2d)==-1) {
						//mouse_in
						me = new MouseEvent(MouseEvent.MOUSE_OVER);
						obj2d.dispatchEvent(me);
					}
				}
				nowMouseObjs = currentMouseObjs;
			}*/
		}
		
		private function exehittest(childs:Array):Boolean {
			if(isNowMouse&&childs){
				for (var i:int = childs.length - 1; i >= 0;i-- ) {
					var obj2d:GpuObj2d = childs[i];
					var flag:Boolean;
					if (exehittest(obj2d.childs)) {
						flag = true;
					}else if(obj2d.mouseEnabled){
						flag = ihittest.hittest(mouseX, mouseY, obj2d);
					}
					if (flag) {
						currentMouseObjs.push(obj2d);
						return flag;
					}
				}
			}
			return false;
		}
		
		/*private function doobj(obj2d:GpuObj2d):void {
			if (obj2d.change) {
				obj2d.recompose();
			}
			obj2d.wmatrix.rawData = obj2d.vmatrix.rawData;
			if (obj2d.parent) {
				obj2d.wmatrix.append(obj2d.parent.wmatrix);
			}
			obj2d.update();
			
			if(obj2d.texture){
				c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, obj2d.selfMatrix, true);
				c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, obj2d.wmatrix, true);
				
				c3d.setTextureAt(0, textures[obj2d.texture.textureId]);
				
				c3d.setVertexBufferAt(1, obj2d.texture.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				c3d.drawTriangles(ibuf);
			}
			if (obj2d.childs) {
				for each(var ob:GpuObj2d in obj2d.childs) {
					doobj(ob);
				}
			}
		}*/
		
		/**
		 * 通过bmd得到texture
		 * @param	bmd
		 * @param	layer
		 * @return
		 */
		/*public function getTexture(bmd:BitmapData, layer:Boolean = false):UVTexture {
			if (textureLib[bmd] == null||layer) {
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
				if (textureLib[bmd]&&layer) {
					var texture:Texture = textures[textureLib[bmd].textureId];
				}else {
					texture = c3d.createTexture(w,h,Context3DTextureFormat.BGRA,false);
				}
				texture.uploadFromBitmapData(temp);
				textures[nowTextureId] = texture;
				temp.dispose();
				
				var uvtexture:UVTexture = new UVTexture;
				uvtexture.textureId = nowTextureId;
				uvtexture.uvBuffer = c3d.createVertexBuffer(4, 2);
				uvtexture.uvBuffer.uploadFromVector(Vector.<Number>([0,0,1,0,0,1,1,1]), 0, 4);
				nowTextureId++;
				
				textureLib[bmd] = uvtexture;
			}
			return textureLib[bmd];
		}*/
		
		/**
		 * 添加显示对象
		 * @param	obj2d
		 */
		public function add(obj2d:GpuObj2d):void {
			_root.add(obj2d);
		}
		
		/**
		 * 移除对象
		 * @param	obj2d
		 */
		public function remove(obj2d:GpuObj2d):void {
			_root.remove(obj2d);
		}
		
		/**
		 * 设置碰撞检测类
		 */
		public function get ihittest():FastPixelHittest 
		{
			return _ihittest;
		}
		
		public function set ihittest(value:FastPixelHittest):void 
		{
			_ihittest = value;
			if (stage == null) return;
			if (value) {
				stage.addEventListener(MouseEvent.CLICK, onMC);
				stage.addEventListener(MouseEvent.DOUBLE_CLICK, onDC);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMU);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMM);
			}else {
				stage.removeEventListener(MouseEvent.CLICK, onMC);
				stage.removeEventListener(MouseEvent.DOUBLE_CLICK, onDC);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMD);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMU);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMM);
			}
		}
		
		private var isNowMouse:Boolean = true;
		private function dispatch(e:Event):void {
			if (e.target is Stage) {
				isNowMouse = true;
				if(nowMouseObjs.length>0){
					for each(var obj:GpuObj2d in nowMouseObjs) {
						var e:Event = e.clone();
						obj.dispatchEvent(e);
					}
				}
			}else {
				isNowMouse = false;
			}
		}
		
		private function onMM(e:MouseEvent):void 
		{
			dispatch(e);
		}
		
		private function onMU(e:MouseEvent):void 
		{
			dispatch(e);
		}
		
		private function onMD(e:MouseEvent):void 
		{
			dispatch(e);
		}
		
		private function onDC(e:MouseEvent):void 
		{
			dispatch(e);
		}
		
		private function onMC(e:MouseEvent):void 
		{
			dispatch(e);
		}
		
		/**
		 * 设置视口的x坐标
		 */
		override public function set x(value:Number):void {
			super.x = value;
			if (stage3d) {
				stage3d.x = x;
			}
		}
		
		/**
		 * 设置视口的y坐标
		 */
		override public function set y(value:Number):void {
			super.y = value;
			if (stage3d) {
				stage3d.y = y;
			}
		}
		
		/**
		 * 视口的高度
		 */
		public function get viewWidth():Number 
		{
			return _viewWidth;
		}
		
		public function set viewWidth(value:Number):void 
		{
			_viewWidth = value;
			
			updateCam();
			
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * 视口的高度
		 */
		public function get viewHeight():Number 
		{
			return _viewHeight;
		}
		
		public function set viewHeight(value:Number):void 
		{
			_viewHeight = value;
			updateCam();
			
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		
		private function updateCam():void {
			if (c3d) {
				cammatrix = new Matrix3D;
				cammatrix.appendScale(2 / viewWidth, 2 / viewHeight, 1);
				cammatrix.appendTranslation( -1, 1, 0);
				
				//c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, cammatrix , true);
				
				c3d.configureBackBuffer(viewWidth, viewHeight, antiAlias, false);
			}
		}
		
		/**
		 * 设置alias
		 */
		public function get antiAlias():int 
		{
			return _antiAlias;
		}
		
		public function set antiAlias(value:int):void 
		{
			_antiAlias = value;
			if(c3d)c3d.configureBackBuffer(viewWidth, viewHeight, antiAlias, false);
		}
	}

}