package net.game_develop.animation.utils 
{
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author lizhi
	 */
	public class InsertBox 
	{
		public var width:int;
		public var height:int;
		public var wrapperRect:Rectangle;
		public var boxs:Array = [];
		public function InsertBox(width:int,height:int) 
		{
			this.height = height;
			this.width = width;
			wrapperRect = new Rectangle(0, 0, width, height);
		}
		
		public function add(rect:Rectangle):Boolean {
			if (boxs.length==0) {
				rect.x = rect.y = 0;
				if (test(rect)) {
					boxs.push(rect);
					return true;
				}
			}
			for each(var box:Rectangle in boxs) {
				rect.x = box.right;
				rect.y = box.top;
				if (test(rect)) {
					boxs.push(rect);
					return true;
				}
			}
			for each(box in boxs) {
				rect.x = box.left;
				rect.y = box.bottom;
				if (test(rect)) {
					boxs.push(rect);
					return true;
				}
			}
			return false;
		}
		
		private function test(rect:Rectangle):Boolean {
			if (!wrapperRect.containsRect(rect)) {
				return false;
			}
			for each(var box:Rectangle in boxs) {
				if (box.intersects(rect)) {
					return false;
				}
			}
			return true;
		}
		
		
		public function clear():void {
			boxs = [];
		}
	}

}