package net.game_develop.animation.utils 
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	/**
	 * ui类
	 * @author lizhi
	 */
	public class TitleCore 
	{
		private var title:InteractiveObject;
		private var target:DisplayObject;
		
		private var sx:Number;
		private var sy:Number;
		public function TitleCore(title:InteractiveObject,target:DisplayObject) 
		{
			this.title = title;
			this.target = target;
			title.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		private function onMouseDown(e:MouseEvent):void {
			sx = target.x - title.stage.mouseX;
			sy = target.y - title.stage.mouseY;
			title.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			title.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		private function onMouseMove(e:MouseEvent):void {
			if (title.stage.mouseX < 0 || title.stage.mouseY < 0 || title.stage.mouseX > title.stage.stageWidth || title.stage.mouseY > title.stage.stageHeight) return;
			target.x = title.stage.mouseX + sx;
			target.y = title.stage.mouseY + sy;
			//e.updateAfterEvent();
		}
		private function onMouseUp(e:MouseEvent):void {
			title.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			title.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
	}

}