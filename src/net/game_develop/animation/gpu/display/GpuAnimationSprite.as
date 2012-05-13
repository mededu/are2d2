package net.game_develop.animation.gpu.display 
{
	import flash.display.BitmapData;
	/**
	 * gpu动画
	 * @author lizhi
	 */
	public class GpuAnimationSprite extends GpuObj2d
	{
		
		public var isPlaying:Boolean = false;
		public var currentAnimationName:String;
		private var currentAnimationData:GpuAnimationData;
		private var currentBase:GpuAnimationBase;
		private var _frame:uint;
		public var animations:Array;
		public var gridindexs:Array;
		
		public var scaleGap:Number = 1;
		
		private var scripts:Array = [];
		private var calbaks:Array;
		public function GpuAnimationSprite() 
		{
			super(1, 1, null);
		}
		
		override public function update():void {
			super.update();
			updateAnimation();
		}
		
		override public function updateAnimation():void {
			if (isPlaying && currentAnimationData) {
				if (_frame * scaleGap >= currentAnimationData.frames.length) _frame = 0;
					var base:GpuAnimationBase = currentAnimationData.textures[currentAnimationData.frames[int(_frame * scaleGap)]];
					_bmd = base.bmd;
					texture = base.texture;
					uv = base.uv;
					uvvertexBuffer = base.uvvertexBuffer;
					selfMatrix = base.selfMatrix;
					vouts = base.vouts;
					selfChange = true;
					currentBase = base;
				if (calbaks && calbaks[_frame]) calbaks[_frame](this);
				_frame++;
			}
		}
		
		public function addFrameScript(name:String, frame:int, calbak:Function):void {
			if (scripts[name] == null) {
				scripts[name] = [];
				if (currentAnimationName == name) calbaks = scripts[name];
			}
			scripts[name][frame] = calbak;
		}
		
		public function play(name:String, frame:int = 0):void {
			isPlaying = true;
			_frame = frame;
			currentAnimationName = name;
			currentAnimationData = animations[name];
			try{
			selfMatrix = currentAnimationData.textures[0].selfMatrix;
			}catch(err:*){}
			calbaks = scripts[name];
		}
		public function stop(name:String, frame:int = 0):void {
			play(name, frame);
			updateAnimation();
			_frame = frame;
			isPlaying = false;
		}
		public function addAnimation(ani:GpuAnimationData):GpuAnimationData {
			if (animations==null) animations = [];
			animations[ani.name] = ani;
			return ani;
		}
		
		public function get frame():uint 
		{
			return _frame;
		}
		
		override public function get bmd():BitmapData 
		{
			if (currentBase == null) return null;
			return currentBase.bmd;
		}
		
		override public function get width():Number
		{
			return selfMatrix.rawData[0];
		}
		
		override public function get height():Number
		{
			return selfMatrix.rawData[5];
		}
		
		override public function get offsetX():Number
		{
			return selfMatrix.position.x;
		}
		
		override public function get offsetY():Number
		{
			return -selfMatrix.position.y;
		}
	}

}