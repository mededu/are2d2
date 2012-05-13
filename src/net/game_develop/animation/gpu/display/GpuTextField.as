package net.game_develop.animation.gpu.display 
{
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import net.game_develop.animation.utils.Pen;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GpuTextField extends GpuObj2d  implements IGpuTextField 
	{
		public var textField:TextField;
		public function GpuTextField(view:GpuView2d,text:String="ARE2D",textField:TextField=null) 
		{
			super(1,1,null);
			this.textField = textField;
			if (textField == null) {
				this.textField = new TextField;
				this.textField.autoSize = TextFieldAutoSize.LEFT;
			}
			this.text = text;
		}
		
		public function textField_change():void 
		{
			var bmd:BitmapData = Pen.getBmdFromDisplay(textField);
			width = bmd.width;
			height = bmd.height;
			offsetX = 0;
			offsetY = 0;
			this.bmd = bmd;
			trysetView();
			//setBmd(bmd, 0, 0);
		}
		
		/* INTERFACE net.game_develop.animation.gpu.IGpuTextField */
		
		public function set text(value:String):void 
		{
			if(value!=textField.text){
				textField.text = value;
				textField_change();
			}
		}
		
		public function get text():String 
		{
			return textField.text;
		}
		
	}

}