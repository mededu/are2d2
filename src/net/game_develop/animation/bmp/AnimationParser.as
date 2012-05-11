package net.game_develop.animation.bmp 
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * 动画分析工具，把多种格式分析成 AnimationData
	 * @author lizhi
	 */
	public class AnimationParser 
	{
		/**
		 * 最基本的生成函数
		 */
		static public function parser(bmds:Vector.<BitmapData>,frames:Vector.<uint>, offset:Point,name:String):AnimationData {
			var ani:AnimationData = new AnimationData;
			ani.bmds = bmds;
			ani.updateWH();
			ani.frames = frames;
			ani.name = name;
			ani.offset = offset;
			return ani;
		}
		
		/**
		 * 动态间隔生成
		 */
		static public function parserDynamicGap(bmds:Vector.<BitmapData>, gap:int, offset:Point, name:String):AnimationData {
			var frames:Vector.<uint> = new Vector.<uint>;
			for (var i:int = 0; i < bmds.length;i++ ) {
				for (var j:int = 0; j <= gap;j++ ) {
					frames.push(i);
				}
			}
			return parser(bmds,frames,offset,name);
		}
		
		/**
		 * 根据rect生成
		 */
		static public function parserByRectsAndGap(bmd:BitmapData, rects:Vector.<Rectangle>, gap:int, offset:Point, name:String):AnimationData {
			var bmds:Vector.<BitmapData> = new Vector.<BitmapData>;
			for (var i:int = 0; i < rects.length; ++i)
			{
				var rect:Rectangle = rects[i];
				var bmd1:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
				bmd1.setVector(bmd1.rect, bmd.getVector(rect));
				bmds.push(bmd1);
			}
			return parserDynamicGap(bmds, gap, offset, name);
		}
		
		static public function parserByIndexs(bmd:BitmapData, sw:int, sh:int, gap:int, indexs:Vector.<uint>,offset:Point, name:String):AnimationData {
			var numCols:int = int(bmd.width / sw);
			var bmds:Vector.<BitmapData> = new Vector.<BitmapData>;
			var rect:Rectangle = new Rectangle(0, 0, sw, sh);
			for each(var i:int in indexs) {
				var x:int = i % numCols;
				var y:int = i / numCols;
				var bmd1:BitmapData = new BitmapData(sw, sh, true, 0);
				rect.x = x * sw;
				rect.y = y * sh;
				bmd1.setVector(bmd1.rect, bmd.getVector(rect));
				bmds.push(bmd1);
			}
			return parserDynamicGap(bmds, gap, offset, name);
		}
		
		
		/**
		 * 根据rect offset生成
		 */
		static public function parserByRectsOffsetsAndGap(bmd:BitmapData, rects:Vector.<Rectangle>, offsets:Vector.<Point>,gap:int, offset:Point, name:String):AnimationData {
			var ani:AnimationData =  parserByRectsAndGap(bmd, rects, gap, offset, name);
			return ani;
		}
		
		/**
		 * 根据MovieClip生成动画数据
		 * @param	mc
		 * @param	name
		 * @param	gap
		 * @return
		 */
		static public function parserByMovieClip(mc:MovieClip, name:String, gap:int = 0):AnimationData {
			var rects:Array = [];
			var w:Sprite = new Sprite;
			w.addChild(mc);
			var bmds:Vector.<BitmapData> = new Vector.<BitmapData>;
			var minX:int = int.MAX_VALUE;
			var minY:int = int.MAX_VALUE;
			for (var i:int = 0; i < mc.totalFrames;i++ ) {
				mc.gotoAndStop(i + 1);
				var r:Rectangle = w.getBounds(w);
				minX = Math.min(minX, r.x);
				minY = Math.min(minY, r.y);
				rects.push(r);
			}
			for (i = 0; i < mc.totalFrames; i++ ) {
				mc.gotoAndStop(i + 1);
				r = rects[i];
				r.left = minX;
				r.top = minY;
				var bmd:BitmapData = new BitmapData(Math.max(1, r.width), Math.max(1, r.height), true, 0);
				bmd.draw(w, new Matrix(1, 0, 0, 1, -r.x, -r.y));
				bmds.push(bmd);
			}
			return parserDynamicGap(bmds,gap,new Point(minX,minY),name);
		}
		
		
	}

}