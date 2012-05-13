package net.game_develop.animation.gpu.display 
{
	import flash.display.BitmapData;
	/**
	 * gpu textfield
	 * @author lizhi
	 */
	public class GpuImageTextField extends GpuObj2d implements IGpuTextField
	{
		private var _text:String;
		private var code:String;
		private var images:Vector.<BitmapData>;
		public function GpuImageTextField(code:String,images:Vector.<BitmapData>) 
		{
			super(1, 1, null);
			this.images = images;
			this.code = code;
			
		}
		
		/* INTERFACE net.game_develop.animation.gpu.IGpuTextField */
		
		public function set text(value:String):void 
		{
			_text = value;
			render();
		}
		
		public function get text():String 
		{
			return _text;
		}
		
		public function render():void {
			for (var i:int = 0, len:int = _text.length; i < len;i++ ) {
				var str:String = _text.charAt(i);
				if (str=="\n") {
					
				}else if (str==" ") {
					
				}else {
					
				}
			}
		}
	}

}