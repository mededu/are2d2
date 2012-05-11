package  
{
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import mx.utils.LoaderUtil;
	/**
	 * ...
	 * @author lizhi
	 */
	public class YedianAssetsGeter extends Sprite
	{
		private var anames:Array;
		private var start:int;
		private var end:int;
		private var p:int;
		private var assets:Array = [];
		public function YedianAssetsGeter() 
		{
			start = 1;
			end = 23;
			p = start;
			anames = ["walk_1","walk_2","dance_a_1"];
			load();
			
		}
		
		private function load():void {
			if (p > end) {
				var ba:ByteArray = new ByteArray;
				ba.writeObject(assets);
				var file:FileReference = new FileReference;
				file.save(ba, "yedian");
				
				return;
			}
			trace(p);
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			loader.load(new URLRequest("assets/player_f" + (p < 10?"000":"00") + p + ".swf"), new LoaderContext(false, ApplicationDomain.currentDomain));
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			p++;
			load();
		}
		
		private function loader_complete(e:Event):void 
		{
			var arr:Array = [];
			for each(var name:String in anames) {
				arr[name] = [];
				var dc:Object = getDefinitionByName("player_f" + (p < 10?"000":"00") + p + "_" + name);
				var bmd:BitmapData = new dc as BitmapData;
				
				arr[name].push(PNGEncoder.encode(bmd));
				var dccon:Object = getDefinitionByName("player_f" + (p < 10?"000":"00") + p + "_" + name + "con");
				var ba:ByteArray = new dccon as ByteArray;
				arr[name].push(ba);
				
			}
			assets.push(arr);
			p++;
			load();
		}
		
	}

}