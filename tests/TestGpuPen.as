package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.game_develop.animation.gpu.display.GpuObj2d;
	import net.game_develop.animation.gpu.display.GpuTextField;
	import net.game_develop.animation.gpu.GpuView2d;
	import net.game_develop.animation.utils.Stats;
	import net.game_develop.animation.utils.Pen;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestGpuPen extends Sprite
	{
		private var view:GpuView2d;
		private var text:GpuTextField;
		
		public function TestGpuPen() 
		{
			view = new GpuView2d(400, 400);
			addChild(view);
			
			//var lay:GpuSpriteLayer = new GpuSpriteLayer;
			//view.add(lay);
			
			//view.addEventListener(Event.CONTEXT3D_CREATE, view_context3dCreate);
			var obj2d:GpuObj2d = Pen.createRect(200,200, 0xff0000,1);
			obj2d.x = 200;
			obj2d.y = 200;
			//obj2d.rotation = 30;
			//lay.add(obj2d);
			view.add(obj2d);
			
			obj2d = Pen.createRect(200,200, 0xff00,1);
			obj2d.x = 300;
			obj2d.y = 300;
			//obj2d.rotation = 30;
			//lay.add(obj2d);
			view.add(obj2d);
			addChild(new Stats());
		}
		
	}

}