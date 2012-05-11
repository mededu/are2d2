package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import net.game_develop.animation.bmp.*;
	/**
	 * ...
	 * @author ...
	 */
	public class JumpGame extends Sprite
	{
		private var world:World;
		
		[Embed(source='spritechar2.png')]
		private var c:Class;
		private var bmdsource:BitmapData = (new c as Bitmap).bitmapData;
		private var up:AnimationData
		private var right:AnimationData;
		private var down:AnimationData;
		private var left:AnimationData;
		private var sw:int = 24;
		private var sh:int = 32;
		private var player:Player;
		
		//private var mouseDownX:Number;
		//private var mouseDownY:Number;
		
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
		private var gridWidth:Number = bmd0.width/3;
		private var gridHeight:Number = bmd0.height/3;
		private var numCols:int;
		private var numRows:int;
		private var w:int=40;
		private var h:int=40;
		private var mapData:Array;
		private var map:Map;
		private var joy:Joystick;
		public function JumpGame() 
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var mapbmd:BitmapData = new BitmapData(w * gridWidth, h * gridHeight, false, 0);
			mapData = [];
			for (var i:int = 0; i < bmds.length; i++) {
				var bmd:BitmapData = bmds[i];
				var temp:BitmapData = new BitmapData(bmd.width / 3, bmd.height / 3, false, 0);
				for (var py:int = 0; py<temp.height;py++ ) {
					for (var px:int = 0; px < temp.width;px++ ) {
						temp.setPixel(px,py, bmd.getPixel(px * 3, py * 3));
					}
				}
				bmds[i] = temp;
			}
			for (var y:int = 0; y < h;y++ ) {
				mapData[y] = [];
				for (var x:int = 0; x < w; x++ ) {
					var d:int = int(bmds.length * Math.random());
					mapData[y][x] = d==3?1:0;
					bmd = bmds[d];
					mapbmd.setVector(new Rectangle(x * gridWidth, y * gridHeight, gridWidth, gridHeight), bmd.getVector(bmd.rect));
				}
			}
			
			trace(stage.stageWidth, stage.stageHeight);
			map = new Map(stage.stageWidth, stage.stageHeight);
			map.mapBmd = mapbmd;
			addChild(map);
			
			var offset:Point = new Point( -sw / 2, -sh+5);
			var gap:int = 0;
			up = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([0, 1, 2]),offset,"up");
			right = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([3, 4, 5]),offset,"right");
			down = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([6, 7, 8]),offset,"down");
			left = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([9, 10, 11]), offset, "left");
			
			world = new World;
			addChild(world);
			world.start();
			world.clip = new Rectangle(world.x, world.y, stage.stageWidth, stage.stageHeight);
			
			player = new Player(world, up, right, down, left);
			world.add(player);
			player.y = 70;
			player.x = 100;
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			joy = new Joystick;
			addChild(joy);
		}
		
		private function enterFrame(e:Event):void 
		{
			//player.straight--;
			
			if (joy.left) {
				player.vx = -3;
				if (!player.isPlaying || player.currentAnimationName != "left") player.play("left");
			}else if (joy.right) {
				player.vx = 3;
				if (!player.isPlaying || player.currentAnimationName != "right") player.play("right");
			}else {
				player.vx = 0;
				if(player.isPlaying)player.stop(player.currentAnimationName);
			}
			
			if (!player.jumping&&joy.a) {
				player.vy = -10;
				player.jumping = true;
			}
			
			
			
			if (player.jumping) {
				player.vy += 1;
			}
			
			var nowx:int=int(player.x/gridWidth);
			var nowy:int = int(player.y / gridHeight);
			var ptargetx:Number = player.x + player.vx;
			var targetx:int = int(ptargetx / gridWidth);
			var ptargety:Number = player.y + player.vy;
			var targety:int = int(ptargety / gridHeight);
			var collideX:Boolean = false;
			var collideYUp:Boolean = false;
			var collideYDown:Boolean = false;
			if ((mapData[nowy]&&mapData[nowy][targetx]==1)) {//x撞墙
				if (player.vx<0) {
					ptargetx = gridWidth * nowx;
				}else if(player.vx>0){
					ptargetx = gridWidth * nowx + gridWidth - 1;
				}
				targetx = nowx;
				collideX = true;
			}
			
			
			if (mapData[targety]==null||mapData[targety][targetx]==1) {//y撞墙
				if (player.vy<0) {
					ptargety = gridHeight * nowy;
					collideYUp = true;
					player.vy = 0;
				}else if (player.vy>0) {
					ptargety = gridHeight * nowy + gridHeight - 1;
					collideYDown = true;
					player.jumping = false;
					player.vy = 0;
					//player.straight = 10;
				}
				targety = nowy;
			}
			
			
			var nextPY:Number = ptargety + 1;
			var nextY:int = int(nextPY / gridHeight);
			if (mapData[nextY]&&mapData[nextY][targetx]!=1) {
				player.jumping = true;
			}
			
			player.x = ptargetx;
			player.y = ptargety;
			
			world.x = -player.x + stage.stageWidth / 2;
			world.y = -player.y + stage.stageHeight / 2;
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
		
	}

}
import net.game_develop.animation.bmp.*;
class Player extends BitmapDataSprite {
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var jumping:Boolean = false;
	//public var straight:int = 0;
	public function Player(world:World,
	up:AnimationData,
	right:AnimationData,
	down:AnimationData,
	left:AnimationData) {
		super(world);
		scaleGap = 0.2;
		addAnimation(up);
		addAnimation(down);
		addAnimation(right);
		addAnimation(left);
		stop("right");
	}
}