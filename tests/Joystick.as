package  
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TouchEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Joystick extends Sprite
	{
		private var leftKeyCodes:Array = [Keyboard.LEFT,"A".charCodeAt(0)];
		private var rightKeyCodes:Array = [Keyboard.RIGHT,"D".charCodeAt(0)];
		private var downKeyCodes:Array = [Keyboard.DOWN,"S".charCodeAt(0)];
		private var upKeyCodes:Array = [Keyboard.UP, "W".charCodeAt(0)];
		
		private var aKeyCodes:Array = ["J".charCodeAt(0)];
		
		private var startX:Number;
		private var startY:Number;
		private var moveX:Number;
		private var moveY:Number;
		private var touchId:int;
		private var angel:Number;
		
		private var _left:Boolean;
		private var _right:Boolean;
		private var up:Boolean;
		private var down:Boolean;
		
		private var _a:Boolean;
		private var abTouchId:int;
		public function Joystick() 
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBegin);
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBegin2);
			
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			if (leftKeyCodes.indexOf(e.keyCode)!=-1) {
				_left = false;
			}else if (rightKeyCodes.indexOf(e.keyCode)!=-1) {
				_right = false;
			}else if (downKeyCodes.indexOf(e.keyCode)!=-1) {
				down = false;
			}else if (upKeyCodes.indexOf(e.keyCode)!=-1) {
				up = false;
			}else if (aKeyCodes.indexOf(e.keyCode)!=-1) {
				_a = false;
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (leftKeyCodes.indexOf(e.keyCode)!=-1) {
				_left = true;
				_right = false;
			}else if (rightKeyCodes.indexOf(e.keyCode)!=-1) {
				_right = true;
				_left = false;
			}else if (downKeyCodes.indexOf(e.keyCode)!=-1) {
				down = true;
				up = false;
			}else if (upKeyCodes.indexOf(e.keyCode)!=-1) {
				up = true;
				down = false;
			}else if (aKeyCodes.indexOf(e.keyCode)!=-1) {
				_a = true;
			}
		}
		
		private function stage_touchBegin(e:TouchEvent):void 
		{
			if(e.localX<stage.stageWidth/2){
				stage.removeEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBegin);
				stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEnd);
				stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMove);
				touchId = e.touchPointID;
				moveX =startX = e.localX;
				moveY = startY = e.localY;
				show();
			}
		}
		private function stage_touchBegin2(e:TouchEvent):void 
		{
			if(e.localX>stage.stageWidth/2){
				stage.removeEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBegin2);
				stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEnd2);
				abTouchId = e.touchPointID;
				_a = true;
			}
		}
		
		private function stage_touchEnd2(e:TouchEvent):void 
		{
			if(e.touchPointID==abTouchId){
				stage.removeEventListener(TouchEvent.TOUCH_END, stage_touchEnd2);
				stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBegin2);
				_a = false;
			}
		}
		
		private function stage_touchEnd(e:TouchEvent):void 
		{
			if(e.touchPointID==touchId){
				stage.removeEventListener(TouchEvent.TOUCH_MOVE, stage_touchMove);
				stage.removeEventListener(TouchEvent.TOUCH_END, stage_touchEnd);
				stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBegin);
				hide();
			}
		}
		
		private function stage_touchMove(e:TouchEvent):void 
		{
			if (e.touchPointID == touchId) {
				moveX  = e.localX;
				moveY  = e.localY;
				move();
			}
		}
		
		private function show():void {
			move();
		}
		
		private function hide():void {
			angel = -1;
			_left = _right = false;
			graphics.clear();
		}
		
		private function move():void {
			var tempAngel:Number = Math.atan2(moveY - startY, moveX - startX);
			if (angel != tempAngel) {
				angel = tempAngel;
				_right = _left = false;
				graphics.clear();
				graphics.lineStyle(0, 0, 0.5);
				graphics.drawCircle(startX, startY, 80);
				graphics.beginFill(0, 0.5);
				if ((moveY - startY) * (moveY - startY) + (moveX - startX) * (moveX - startX) < 1600) {
					graphics.drawCircle(startX, startY, 30);
				}else{
					if (angel > -Math.PI / 4 && angel <= Math.PI / 4) {
						_right = true;
					}else if (angel>Math.PI*3/4||angel<-Math.PI*3/4) {
						_left = true;
					}
					graphics.drawCircle(startX + 80 * Math.cos(angel), startY + 80 * Math.sin(angel), 30);
				}
				
			}
		}
		
		public function get left():Boolean 
		{
			return _left;
		}
		
		public function get right():Boolean 
		{
			return _right;
		}
		
		public function get a():Boolean 
		{
			return _a;
		}
	}

}