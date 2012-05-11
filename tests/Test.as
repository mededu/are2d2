package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import net.game_develop.animation.gpu.GpuObj2d;
	import net.game_develop.animation.gpu.GpuView2d;
	import net.game_develop.animation.utils.Stats;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		private var view:GpuView2d;
		
		public function Test() 
		{
			view = new GpuView2d(400, 400);
			addChild(view);
			[Embed(source = "g_lea2.png")]var c:Class;
			var bmd:BitmapData = (new c as Bitmap).bitmapData;
			var count:int = 5;
			while(count-->0){
				var obj2d:GpuObj2d = new GpuObj2d(30, 30, bmd);
				obj2d.x = view.viewWidth * Math.random();
				obj2d.y = view.viewHeight * Math.random();
				view.add(obj2d);
			}
			addChild(new Stats());
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			for each(var obj2d:GpuObj2d in view._root.childs) {
				obj2d.rotation++;
			}
		}
		
	}

}