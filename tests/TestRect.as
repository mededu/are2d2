package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import net.game_develop.animation.bmp.AnimationParser;
	import net.game_develop.animation.gpu.*;
	import net.game_develop.animation.utils.Stats;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestRect extends Sprite
	{
		private var rects:Array = [];
		private var angel:Number = Math.PI * 3 / 2;
		private var va:Number = 0.1;
		private var bmds:Array;
		private var view:GpuView2d;
		
		
		[Embed(source='spritechar2.png')]
		private var c:Class;
		private var bmdsource:BitmapData = (new c as Bitmap).bitmapData;
		private var up:GpuAnimationData
		private var right:GpuAnimationData;
		private var down:GpuAnimationData;
		private var left:GpuAnimationData;
		private var sw:int = 24;
		private var sh:int = 32;
		public function TestRect()
		{
			view = new GpuView2d(800, 600);
			addChild(view);
			
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			var layer:GpuObj2d = new GpuSpriteLayer(10000);
			//var layer:GpuObj2d = new GpuObj2d(1, 1, null);
			view.add(layer);
			var c:int = 5;
			bmds = [];
			while (c-- > 0)
			{
				var bmd:BitmapData = new BitmapData(30, 30);
				bmd.perlinNoise(30, 30, 2, 1, true, true);
				bmd.colorTransform(bmd.rect, new ColorTransform(Math.random(), Math.random(), Math.random()));
				bmds.push(bmd);
			}
			
			var offset:Point = new Point( -sw / 2, -sh+5);
			var gap:int = 0;
			up = GpuAnimationParser.formatToGpu(AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([0, 1, 2]),offset,"up"));
			right = GpuAnimationParser.formatToGpu(AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([3, 4, 5]),offset,"right"));
			down = GpuAnimationParser.formatToGpu(AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([6, 7, 8]),offset,"down"));
			left = GpuAnimationParser.formatToGpu(AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([9, 10, 11]), offset, "left"));
			
			c = 5;
			while (c-->0)
			{
				bmd = bmds[int(bmds.length * Math.random())]
				var rect:Rect = new Rect(bmd.width, bmd.height, bmd, view, 0, 0);
				rect.addAnimation(down);
				//rect.scaleGap = 0.2;
				rect.play("down");
				layer.add(rect);
				init(rect);
				rects.push(rect);
			}
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			addChild(new Stats());
		}
		
		private function enterFrame(e:Event):void
		{
			angel += va;
			if (angel > 7 * Math.PI / 4)
			{
				va = -Math.abs(va);
			}
			else if (angel < Math.PI * 5 / 4)
			{
				va = Math.abs(va);
			}
			
			for each (var rect:Rect in rects)
			{
				rect.vy += 0.3;
				rect.x += rect.vx;
				rect.y += rect.vy;
				rect.rotation += rect.rs;
				if (rect.x < 0)
				{
					rect.vx = Math.abs(rect.vx);
				}
				else if (rect.x > view.viewWidth)
				{
					rect.vx = -Math.abs(rect.vx);
				}
				else if (rect.y < 0)
				{
					rect.vy = Math.abs(rect.vy);
				}
				if (rect.y > view.viewHeight)
				{
					init(rect);
				}
				
			}
			
		}
		
		private function init(rect:Rect):void
		{
			rect.x = stage.stageWidth / 2;
			rect.y = stage.stageHeight;
			var l:Number = 20 * Math.random();
			rect.vy = l * Math.sin(angel);
			rect.vx = l * Math.cos(angel);
		}
	}

}
import net.game_develop.animation.gpu.*;

/*class Rect extends GpuObj2d
{
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var rs:Number = (Math.random() - 0.5) * 20;
	public function Rect(width:Number, height:Number, bmd:flash.display.BitmapData, view:net.game_develop.animation.gpu.GpuView2d, x:Number, y:Number)
	{
		super(width, height, bmd, view, x, y);
		this.x = x;
		this.y = y;
	}
}*/

class Rect extends GpuAnimationSprite
{
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var rs:Number = (Math.random() - 0.5) * 20;
	public function Rect(width:Number, height:Number, bmd:flash.display.BitmapData, view:net.game_develop.animation.gpu.GpuView2d, x:Number, y:Number)
	{
		super();
		//super(width, height, bmd, view, x, y);
		this.x = x;
		this.y = y;
	}
}