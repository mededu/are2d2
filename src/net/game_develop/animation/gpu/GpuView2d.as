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
		 * stage3d
		 */
		public var stage3d:Stage3D;
		/**
		 * context3d
		 */
		public var c3d:Context3D;
		/**
		 * 显示对象root
		 */
		public var _root:GpuObj2d;
		private var _viewWidth:Number;
		private var _viewHeight:Number;
		/**
		 * texture库
		 */
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
		
		/**
		 * 
		 * @param	vwidth	视口的宽度
		 * @param	vheight	视口的高度
		 */
		public function GpuView2d(vwidth:Number,vheight:Number) 
		{
			_root = new GpuObj2d(1, 1, null);
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
			
			stage3d.x = x;
			stage3d.y = y;
			
			trace(ARE2D.name, c3d.driverInfo);
			ARE2D.renderMode = c3d.driverInfo;
			cammatrix = new Matrix3D;
			cammatrix.appendScale(2 / viewWidth, 2 / viewHeight, 1);
			cammatrix.appendTranslation( -1, 1, 0);
			start();
			
			dispatchEvent(e.clone());
		}
		
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
			_root.renderer.render(_root,this);
			c3d.present();
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