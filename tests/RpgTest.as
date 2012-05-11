package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.game_develop.animation.bmp.*;
	import net.game_develop.animation.utils.Stats;
	/**
	 * ...
	 * @author lizhi
	 */
	[SWF(frameRate=100)]
	public class RpgTest extends Sprite
	{
		private var matr:Matrix = new Matrix;
		[Embed(source = "g_lea2.png")]private var bg0:Class;
		private var bmd0:BitmapData = (new bg0 as Bitmap).bitmapData;
		[Embed(source = "g_lea7.png")]private var bg1:Class;
		private var bmd1:BitmapData = (new bg1 as Bitmap).bitmapData;
		[Embed(source = "g_snow.png")]private var bg2:Class;
		private var bmd2:BitmapData = (new bg2 as Bitmap).bitmapData;
		[Embed(source="g_stone1.png")]private var bg3:Class;
		private var bmd3:BitmapData = (new bg3 as Bitmap).bitmapData;
		
		private var bmds:Array = [bmd0, bmd1, bmd2, bmd3];
		private var bmdw:int = bmd0.width;
		private var bmdh:int = bmd0.height;
		private var w:int=40;
		private var h:int=40;
		private var map:Map;
		
		
		[Embed(source='spritechar2.png')]
		private var c:Class;
		private var bmdsource:BitmapData = (new c as Bitmap).bitmapData;
		private var up:AnimationData
		private var right:AnimationData;
		private var down:AnimationData;
		private var left:AnimationData;
		private var sw:int = 24;
		private var sh:int = 32;
		
		private var tx:int = -1;
		private var ty:int = -1;
		private var sprite:Particle;
		private var particles:Array=[];
		private var world:World;
		public function RpgTest() 
		{
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var mapbmd:BitmapData = new BitmapData(w * bmdw, h * bmdh, false, 0);
			for (var y:int = 0; y < h;y++ ) {
				for (var x:int = 0; x < w;x++ ) {
					var bmd:BitmapData = bmds[int(bmds.length * Math.random())];
					mapbmd.setVector(new Rectangle(x * bmdw, y * bmdh, bmdw, bmdh), bmd.getVector(bmd.rect));
				}
			}
			
			trace(stage.stageWidth, stage.stageHeight);
			map = new Map(stage.stageWidth, stage.stageHeight);
			map.mapBmd = mapbmd;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			addChild(map);
			world = new World;
			addChild(world);
			world.start();
			world.clip = new Rectangle(world.x, world.y, stage.stageWidth, stage.stageHeight);
			
			var offset:Point = new Point( -sw / 2, -sh+5);
			var gap:int = 0;
			up = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([0, 1, 2]),offset,"up");
			right = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([3, 4, 5]),offset,"right");
			down = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([6, 7, 8]),offset,"down");
			left = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([9, 10, 11]), offset, "left");
			
			
			sprite = new Particle(world);
			sprite.scaleGap = 0.2;
			sprite.x = stage.stageWidth/2;
			sprite.y = stage.stageHeight/2;
			sprite.addAnimation(up);
			sprite.addAnimation(down);
			sprite.addAnimation(right);
			sprite.addAnimation(left);
			world.add(sprite, false);
			sprite.play("down", 0);
			sprite.update();
			addEventListener(MouseEvent.CLICK, click);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			add(100);
			var stats:Stats = new Stats;
			addChild(stats);
			stats.addEventListener(MouseEvent.CLICK, stats_click);
		}
		
		private function stats_click(e:MouseEvent):void 
		{
			add(30);
		}
		
		private function mouseDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		private function mouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		private function mouseMove(e:MouseEvent):void 
		{
			click(null);
		}
		
		private function click(e:MouseEvent):void 
		{
			tx = world.mouseX;
			ty = world.mouseY;
		}
		
		private function enterFrame(e:Event):void 
		{
			
			update();
			if (tx != -1) {
				var speed:Number = 5;
				var a:Number = Math.atan2(ty - sprite.y, tx - sprite.x);
				if (Math.sqrt((tx-sprite.x)*(tx-sprite.x)+(ty-sprite.y)*(ty-sprite.y))<speed) {
					sprite.x = tx;
					sprite.y = ty;
					tx = -1;
				}else {
					var sx:Number = speed * Math.cos(a);
					var sy:Number = speed * Math.sin(a);
					sprite.x += sx;
					sprite.y += sy;
				}
				if (a>-Math.PI*3/4&&a<=-Math.PI/4) {
					sprite.play("up",sprite.frame);
				}else if (a>-Math.PI/4&&a<=Math.PI/4) {
					sprite.play("right",sprite.frame);
				}else if (a>Math.PI/4&&a<=Math.PI*3/4) {
					sprite.play("down",sprite.frame);
				}else{
					sprite.play("left",sprite.frame);
				}
			}else {
				sprite.stop(sprite.currentAnimationName, 0);
			}
			world.x = -sprite.x + stage.stageWidth / 2;
			world.y = -sprite.y + stage.stageHeight / 2;
			world.clip.x = -world.x;
			world.clip.y = -world.y;
			world.clip.width = stage.stageWidth;
			world.clip.height = stage.stageHeight;
			var viewport:Rectangle = map.viewport;
			viewport.x = -world.x;
			viewport.y = -world.y;
			viewport.width = stage.stageWidth;
			viewport.height = stage.stageHeight;
			map.viewport = viewport;
			map.update();
		}
		
		private function add(num:int):void
		{
			while (num-- > 0)
			{
				var sprite:Particle = new Particle(world);
				
                sprite.vx = (Math.random() - Math.random()) * 3;
                sprite.vy = (Math.random() - Math.random()) * 3;
				sprite.scaleGap = Math.sqrt(sprite.vx * sprite.vx + sprite.vy * sprite.vy)/Math.sqrt(18);
				
				sprite.x = stage.stageWidth * Math.random();
				sprite.y = stage.stageHeight * Math.random();
				sprite.addAnimation(up);
				sprite.addAnimation(down);
				sprite.addAnimation(right);
				sprite.addAnimation(left);
				world.add(sprite, false);
				sprite.play("up", 0);
				particles.push(sprite);
				//tail.add(sprite);
			}
		}
		
		private function update():void
		{
			for each(var s:Particle in particles){
				s.x += s.vx;
				s.y += s.vy;
				
				//s.rotation += 10;
				
				if (s.x < -world.x)
				{
					//s.x = 0;
					s.vx = Math.abs(s.vx);
				}
				
				if (s.x > -world.x+stage.stageWidth)
				{
					//s.x = stage.stageWidth;
					s.vx = -Math.abs(s.vx);
				}
				
				if (s.y < -world.y)
				{
					//s.y = 0;
					s.vy = Math.abs(s.vy);
				}
				
				if (s.y >-world.y+ stage.stageHeight)
				{
					//s.y = stage.stageHeight;
					s.vy = -Math.abs(s.vy);
				}
				
				var vxabs:Number = Math.abs(s.vx);
				var vyabs:Number = Math.abs(s.vy);
				
				if (s.vx > 0 && vxabs > vyabs)
				{ // right
					if(s.currentAnimationName!="right")s.play("right",s.frame);
				}
				else if (s.vx < 0 && vxabs > vyabs)
				{ // left
					if(s.currentAnimationName!="left")s.play("left",s.frame);
				}
				else if (s.vy > 0 && vyabs > vxabs)
				{ // down
					if(s.currentAnimationName!="down")s.play("down",s.frame);
				}
				else if (s.vy < 0 && vyabs > vxabs)
				{ // up
					if(s.currentAnimationName!="up")s.play("up",s.frame);
				}
				
				s = s.pre as Particle;
			}
			world.sortByYAndRemoveWhenHide();
		}
	}

}
import net.game_develop.animation.bmp.*;

class Particle extends BitmapDataSprite
{
	public var vx:Number;
	public var vy:Number;
	
	public function Particle(world:World)
	{
		super(world);
	}
}