package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import net.game_develop.animation.gpu.GpuObj2d;
	import net.game_develop.animation.gpu.GpuView2d;
	import net.game_develop.animation.hittests.FastPixelHittest;
	/**
	 * ...
	 * @author lizhi
	 */
	[SWF(width=400,height=400,backgroundColor=0,frameRate=60)]
	public class TestHittest extends Sprite
	{
		private var view:GpuView2d;
		private var hitTest:FastPixelHittest;
		private var obj2d:GpuObj2d;
		
		public function TestHittest() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			view = new GpuView2d(400, 400);
			addChild(view);
			view.ihittest = new FastPixelHittest;
			[Embed(source = "spritechar2.png")]var c:Class;
			var bmd:BitmapData = (new c as Bitmap).bitmapData;
			obj2d = new GpuObj2d(bmd.width*2, bmd.height*2, bmd);
			obj2d.x = 300;
			obj2d.y = 200;
			obj2d.rotation = 45;
			obj2d.scaleX = obj2d.scaleY = 1.5;
			view.add(obj2d);
			obj2d.addEventListener(MouseEvent.MOUSE_OVER, obj2d_mouseOver);
			obj2d.addEventListener(MouseEvent.MOUSE_OUT, obj2d_mouseOut);
			
			
			obj2d = new GpuObj2d(bmd.width*2, bmd.height*2, bmd);
			obj2d.x = 200;
			obj2d.y = 200;
			obj2d.rotation = -45;
			//obj2d.scaleX = obj2d.scaleY = 1.5;
			view.add(obj2d);
			obj2d.addEventListener(MouseEvent.MOUSE_OVER, obj2d_mouseOver);
			obj2d.addEventListener(MouseEvent.MOUSE_OUT, obj2d_mouseOut);
			hitTest = new FastPixelHittest;
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			obj2d.rotation++;
		}
		
		private function obj2d_mouseOut(e:MouseEvent):void 
		{
			var obj2d:GpuObj2d = e.currentTarget as GpuObj2d;
			obj2d.colorTransform = null;
		}
		
		private function obj2d_mouseOver(e:MouseEvent):void 
		{
			
			var obj2d:GpuObj2d = e.currentTarget as GpuObj2d;
			obj2d.colorTransform = new ColorTransform(10);
		}
		
	}

}