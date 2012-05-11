package net.game_develop.animation.bmp 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * 位图渲染类 最基本显示对象
	 * @author lizhi http://game-develop.net/
	 */
	public class BitmapDataSprite extends Sprite
	{
		/**
		 * 链表结构下一个显示对象
		 */
		public var next:BitmapDataSprite;
		/**
		 * 链表结构上一个显示对象
		 */
		public var pre:BitmapDataSprite;
		/**
		 * 显示对象的位图容器
		 */
		public var image:Bitmap;
		/**
		 * 是否在播放动画
		 */
		public var isPlaying:Boolean = false;
		/**
		 * 当前动画的名字
		 */
		public var currentAnimationName:String;
		/**
		 * 当前动画bitmapdata
		 */
		public var currentAnimationBitmapData:BitmapData;
		private var currentAnimationData:AnimationData;
		private var _frame:uint;
		private var animations:Array;
		/**
		 * 包围盒
		 */
		public var bound:Rectangle;
		/**
		 * 网格深度数组
		 */
		public var gridindexs:Array;
		
		/**
		 * 当鼠标经过时执行的回调函数
		 */
		public var onMouseOver:Function;
		/**
		 * 当鼠标离开时执行的回调函数
		 */
		public var onMouseOut:Function;
		
		private var world:World;
		
		/**
		 * 动画的播放速度
		 */
		public var scaleGap:Number = 1;
		
		private var scripts:Array = [];
		private var calbaks:Array;
		
		/**
		 * 是否隐藏
		 */
		public var visableBmd:Boolean = true;
		
		/**
		 * 构造函数
		 * @param	world 传入它的世界
		 */
		public function BitmapDataSprite(world:World) 
		{
			this.world = world;
		}
		
		/**
		 * 刷新
		 */
		public function update():void {
			/*if (currentAnimationData) {
				if (_frame  >= currentAnimationData.frames.length) _frame = 0;
				image.bitmapData = currentAnimationData.bmds[_frame];// currentAnimationBitmapData;
				_frame++;
			}*/
			
			if (isPlaying && currentAnimationData) {
				if (_frame * scaleGap >= currentAnimationData.frames.length) _frame = 0;
				if(visableBmd){
					currentAnimationBitmapData = currentAnimationData.bmds[currentAnimationData.frames[int(_frame*scaleGap)]];
					if (image.bitmapData != currentAnimationBitmapData){
						image.bitmapData = currentAnimationBitmapData;
						//world.render.rendlist.push(image,currentAnimationBitmapData);
					}
				}else {
					currentAnimationBitmapData = null;
					image.bitmapData = null;
					//world.render.rendlist.push(image,null);
				}
				if (calbaks && calbaks[_frame]) calbaks[_frame](this);
				_frame++;
			}
		}
		
		/**
		 * 添加回调函数到某帧上
		 * @param	name	动画的名字
		 * @param	frame	标签
		 * @param	calbak	回调函数
		 */
		public function addFrameScript(name:String, frame:int, calbak:Function):void {
			if (scripts[name] == null) {
				scripts[name] = [];
				if (currentAnimationName == name) calbaks = scripts[name];
			}
			scripts[name][frame] = calbak;
		}
		
		/**
		 * 开始播放某个动画
		 * @param	name	动画的名字
		 * @param	frame	开始播放动画的帧
		 */
		public function play(name:String, frame:int = 0):void {
			isPlaying = true;
			_frame = frame;
			currentAnimationName = name;
			currentAnimationData = animations[name];
			if (image == null) {
				image = new Bitmap;
				addChild(image);
			}
			image.x = currentAnimationData.offset.x;
			image.y = currentAnimationData.offset.y;
			calbaks = scripts[name];
		}
		
		/**
		 * 停止播放动画
		 * @param	name	动画的名字
		 * @param	frame	动画的帧
		 */
		public function stop(name:String, frame:int = 0):void {
			play(name, frame);
			update();
			_frame = frame;
			isPlaying = false;
		}
		
		/**
		 * 添加动画到这个显示对象
		 * @param	ani	动画数据
		 * @return
		 */
		public function addAnimation(ani:AnimationData):AnimationData {
			if (bound == null) bound = new Rectangle;
			if (bound.left > ani.offset.x) bound.left = ani.offset.x;
			if (bound.top > ani.offset.y) bound.top = ani.offset.y;
			if (bound.right < ani.offset.x + ani.wh.x) bound.right = ani.offset.x + ani.wh.x;
			if (bound.bottom < ani.offset.y + ani.wh.y) bound.bottom = ani.offset.y + ani.wh.y;
			if (animations==null) animations = [];
			animations[ani.name] = ani;
			return ani;
		}
		
		/**
		 * 当前帧
		 */
		public function get frame():uint 
		{
			return _frame;
		}
	}

}