package  
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import net.game_develop.animation.bmp.AnimationParser;
	import net.game_develop.animation.gpu.display.GpuObj2d;
	import net.game_develop.animation.gpu.display.GpuSpriteLayer;
	import net.game_develop.animation.gpu.GpuView2d;
	import net.game_develop.animation.hittests.FastPixelHittest;
	/**
	 * ...
	 * @author lizhi
	 */
	public class DragAndSetChildIndex extends Sprite
	{
		
		public function DragAndSetChildIndex() 
		{
			view = new GpuView2d(400, 400);
			addChild(view);
			view.ihittest = new FastPixelHittest;
			
			//layer = new GpuSpriteLayer;
			layer = new GpuObj2d;
			view.add(layer);
			
			var bmp:BitmapData = new BitmapData(10, 10, true, 0xffff0000);
			var ob2d:GpuObj2d = new GpuObj2d(50, 70, bmp);
			layer.add(ob2d);
			ob2d.x = 200;
			ob2d.y = 200;
			ob2d.addEventListener(MouseEvent.MOUSE_DOWN, ob2d_mouseDown);
			
			bmp = new BitmapData(10, 10, true, 0xff00ff00);
			ob2d = new GpuObj2d(50, 70, bmp);
			layer.add(ob2d);
			ob2d.x = 220;
			ob2d.y = 220;
			ob2d.addEventListener(MouseEvent.MOUSE_DOWN, ob2d_mouseDown);
			
			var tf:TextField = new TextField;
			tf.autoSize = TextFieldAutoSize.LEFT;
			addChild(tf);
			tf.text = "drag item 拖动物体";
		}
		
		private var current:GpuObj2d;
		private var dx:Number;
		private var dy:Number;
		private var view:GpuView2d;
		private var layer:GpuObj2d;
		private function ob2d_mouseDown(e:MouseEvent):void 
		{
			current = e.currentTarget as GpuObj2d;
			dx = -mouseX + current.x;
			dy = -mouseY + current.y;
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			layer.setChildIndex(current, layer.childs.length - 1);
		}
		
		private function enterFrame(e:Event):void 
		{
			current.x = dx + mouseX;
			current.y = dy + mouseY;
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
	}

}