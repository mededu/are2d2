package net.game_develop.animation.bmp 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.game_develop.animation.utils.ARE2D;
	/**
	 * bitmapdata渲染的容器
	 * @author lizhi http://game-develop.net/
	 */
	public class World extends BitmapDataSprite
	{
		private var sprite:BitmapDataSprite;
		private var endSprite:BitmapDataSprite;
		private var sprites:Array;
		private var mouseSprites:Vector.<BitmapDataSprite>;
		
		private var grid:Array;
		private var _gridWidth:Number = 123;
		private var _gridHeight:Number = 58;
		private var firstPoint:Point = new Point;
		private var secondObject:Point = new Point;
		private var lastMouseSprite:BitmapDataSprite;
		private var rimage:Bitmap;
		private var bmd:BitmapData;
		//public var render:AnimationRender;
		
		/**
		 * 指定容器的裁剪，如果超出clip范围会自动剔除
		 */
		public var clip:Rectangle;
		public function World() 
		{
			super(null);
			//cacheAsBitmap = true;
			sprites = [];
			//mouseEnabled = false;
			//mouseChildren = false;
			//render = new AnimationRender;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			ARE2D.addMenu(this);
		}
		
		/**
		 * 添加sprite
		 * @param	sprite	位图显示对象
		 * @param	enableMouse	是否允许侦听鼠标事件
		 * @return
		 */
		public function add(sprite:BitmapDataSprite,enableMouse:Boolean=false):BitmapDataSprite {
			addChild(sprite);
			if (this.sprite == null) {
				this.sprite = sprite;
			}else {
				endSprite.next = sprite;
				sprite.pre = endSprite;
			}
			endSprite = sprite;
			if (enableMouse) {
				addToGrid(sprite);
				addEventListener(MouseEvent.MOUSE_MOVE, testGrid);
				addEventListener(MouseEvent.MOUSE_OUT, testGrid);
				if (mouseSprites == null) mouseSprites = new Vector.<BitmapDataSprite>;
				mouseSprites.push(sprite);
			}
			sprites.push(sprite);
			return sprite;
		}
		
		/**
		 * 一种深度排序方法 根据y的坐标进行深度排序
		 */
		public function sortByY():void {
			sprites.sortOn("y", Array.NUMERIC);
			while (numChildren > 0) {
				removeChildAt(0);
			}
			for each(var s:BitmapDataSprite in sprites) {
				addChild(s);
			}
		}
		
		/**
		 * 根据y轴排序 并且剔除 显示对象 当显示对象 visable为 false时
		 */
		public function sortByYAndRemoveWhenHide():void {
			sprites.sortOn("y", Array.NUMERIC);
			while (numChildren > 0) {
				removeChildAt(0);
			}
			for each(var s:BitmapDataSprite in sprites) {
				if(s.visableBmd)addChild(s);
			}
		}
		
		/**
		 * 重置网格不进行排序 鼠标检测初始化用 详情参考例子
		 */
		public function resetGridNoSort():void {
			grid = [];
			for each(var sprite:BitmapDataSprite in mouseSprites) {
				for (var y:int = (sprite.y+sprite.bound.top)/ _gridHeight; y < int((sprite.y+sprite.bound.bottom) / _gridHeight) + 1;y++ ) {
					if (grid[y] == null) grid[y] = [];
					for (var x:int = (sprite.x+sprite.bound.left) / _gridWidth; x < int((sprite.x+sprite.bound.right) / _gridWidth) + 1;x++ ) {
						if (grid[y][x] == null) grid[y][x] = [];
						grid[y][x].unshift(sprite);
					}
				}
			}
		}
		
		/**
		 * 添加显示对象到网格 鼠标检测用 详情参考例子
		 * @param	sprite
		 */
		public function addToGrid(sprite:BitmapDataSprite):void {
			if (grid == null) grid = [];
			if (sprite.gridindexs) {
				for (var i:int = 0; i < sprite.gridindexs.length;i+=2 ) {
					var x:int = sprite.gridindexs[i];
					var y:int = sprite.gridindexs[i + 1];
					if (grid[y] && grid[y][x]) {
						var index:int = grid[y][x].indexOf(sprite);
						if (index != -1) grid[y][x].splice(index, 1);
					}
				}
			}
			
			sprite.gridindexs = [];
			for (y = (sprite.y+sprite.bound.top)/ _gridHeight; y < int((sprite.y+sprite.bound.bottom) / _gridHeight) + 1;y++ ) {
				if (grid[y] == null) grid[y] = [];
				for (x = (sprite.x+sprite.bound.left) / _gridWidth; x < int((sprite.x+sprite.bound.right) / _gridWidth) + 1;x++ ) {
					if (grid[y][x] == null) grid[y][x] = [];
					var flag:Boolean = true;
					for (i = 0; i < grid[y][x].length;i++ ) {
						var temp:BitmapDataSprite = grid[y][x][i];
						if (getChildIndex(temp)<getChildIndex(sprite)) {
							grid[y][x].splice(i, 0, sprite);
							flag = false;
							break;
						}
					}
					if (flag) grid[y][x].push(sprite);
					sprite.gridindexs.push(x, y);
				}
			}
		}
		
		//格子鼠标碰撞检测类
		private function testGrid(e:MouseEvent):void 
		{
			var x:int = mouseX / _gridWidth;
			var y:int = mouseY / _gridHeight;
			var flag:Boolean = false;
			if (grid && grid[y] && grid[y][x]) {
				for each(var sprite:BitmapDataSprite in grid[y][x]){
					var bmd:BitmapData = sprite.currentAnimationBitmapData;
					firstPoint.x = sprite.x;
					firstPoint.y = sprite.y;
					secondObject.x = mouseX;
					secondObject.y = mouseY;
					if (bmd.hitTest(firstPoint,0,secondObject)) {
						if (sprite == lastMouseSprite) {
							
						}else {
							if (lastMouseSprite) {
								if (lastMouseSprite.onMouseOut!=null) lastMouseSprite.onMouseOut(lastMouseSprite);
							}
							lastMouseSprite = sprite;
							if (lastMouseSprite.onMouseOver!=null) lastMouseSprite.onMouseOver(lastMouseSprite);
						}
						flag = true;
						break;
					}
				}
			}
			
			if (!flag&&lastMouseSprite) {
				if (lastMouseSprite.onMouseOut!=null) lastMouseSprite.onMouseOut(lastMouseSprite);
				lastMouseSprite = null;
			}
		}
		
		/**
		 * 删除显示对象从显示列表里
		 * @param	sprite
		 * @return
		 */
		public function remove(sprite:BitmapDataSprite):BitmapDataSprite {
			return null;
		}
		
		/**
		 * 刷新动画
		 */
		override public function update():void {
			super.update();
			var temp:BitmapDataSprite = sprite;
			//render.rendlist = [];
			while (temp) {
				if (clip&&temp.bound&&!((temp.x+temp.bound.right>clip.left)&&(temp.x+temp.bound.left<clip.right)&&(temp.y+temp.bound.bottom>clip.top)&&(temp.y+temp.bound.top<clip.bottom))) {
					temp.visableBmd = false;
				}else {
					temp.visableBmd = true;
				}
				temp.update();
				temp = temp.next;
			}
			
			/*for (var i:int = 0,len:int=render.rendlist.length; i < len;i+=2 ) {
				rimage = render.rendlist[i];
				bmd = render.rendlist[i + 1];
				rimage.bitmapData = bmd;
			}*/
		}
		
		/**
		 * 开始渲染
		 */
		public function start():void {
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		/**
		 * 停止渲染
		 */
		public function pause():void {
			removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		private function enterFrame(e:Event):void {
			update();
		}
		
		/**
		 * 容器的宽度
		 */
		public function set gridWidth(value:Number):void 
		{
			_gridWidth = value;
		}
		
		/**
		 * 容器的高度
		 */
		public function set gridHeight(value:Number):void 
		{
			_gridHeight = value;
		}
	}

}