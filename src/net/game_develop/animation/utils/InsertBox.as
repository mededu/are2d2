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
		//public var wrapperRect:Rectangle;
		public var boxs:Array = [];
		//private var lastY:int = 0;
		private var currentY:int = 0;
		private var ix:int = 0;
		private var iy:int = 0;
		public function InsertBox(width:int,height:int) 
		{
			this.height = height;
			this.width = width;
			//wrapperRect = new Rectangle(0, 0, width, height);
		}
		
		public function add(rect:Rectangle):Boolean {
			rect.x = ix;
			rect.y = iy;
			if (rect.bottom > height) return false;
			if (rect.right > width) {
				rect.x = 0;
				rect.y = currentY;
				if (rect.bottom > height) {
					return false;
				}else {
					boxs.push(rect);
					ix = rect.width;
					iy = rect.y;
				}
			}else {
				boxs.push(rect);
				ix += rect.width;
			}
			currentY =Math.max(currentY,rect.bottom);
			return true;
			/*if (boxs.length==0) {
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
			return false;*/
		}
		
		/*private function test(rect:Rectangle):Boolean {
			if (!wrapperRect.containsRect(rect)) {
				return false;
			}
			for each(var box:Rectangle in boxs) {
				if (box.intersects(rect)) {
					return false;
				}
			}
			return true;
		}*/
		
		
		public function clear():void {
			boxs = [];
		}
	}

}