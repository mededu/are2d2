package  
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import net.game_develop.animation.bmp.*;
	import realtimelib.*;
	import realtimelib.events.*;
	import realtimelib.session.*;
	
	/**
	 * ...
	 * @author lizhi
	 */
	/*[SWF(width=465,height=465,backgroundColor=0,frameRate=60)]*/
	public class P2PRpgTest extends Sprite
	{
		private var p2p:P2PGame;
		
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
		private var sprite:BitmapDataSprite;
		private var world:World;
		
		private var players:Array = [];
		public function P2PRpgTest() 
		{
			P2PSession.debugMode = true;
			p2p = new P2PGame("rtmfp://p2p.rtmfp.net/fe0704d85bec8171e0f35e7a-4e39644da8a0/");

			//P2PSession.isLocal = true;
			//p2p = new P2PGame("rtmfp:");
			
			p2p.addEventListener(Event.CONNECT, p2p_connect);
			p2p.addEventListener(Event.CHANGE, p2p_change);
			p2p.connect("lizhi" + Math.random());
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var mapbmd:BitmapData = new BitmapData(w * bmdw, h * bmdh, false, 0);
			for (var y:int = 0; y < h;y++ ) {
				for (var x:int = 0; x < w;x++ ) {
					var bmd:BitmapData = bmds[int(bmds.length * Math.random())];
					mapbmd.setVector(new Rectangle(x * bmdw, y * bmdh, bmdw, bmdh), bmd.getVector(bmd.rect));
				}
			}
			
			map = new Map(stage.stageWidth, stage.stageHeight);
			map.mapBmd = mapbmd;
			
			addChild(map);
			world = new World;
			addChild(world);
			world.start();
			
			var offset:Point = new Point( -sw / 2, -sh+5);
			var gap:int = 0;
			up = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([0, 1, 2]),offset,"up");
			right = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([3, 4, 5]),offset,"right");
			down = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([6, 7, 8]),offset,"down");
			left = AnimationParser.parserByIndexs(bmdsource, sw, sh, gap, Vector.<uint>([9, 10, 11]), offset, "left");
			
			
			sprite = addPlayer(stage.stageWidth/2, stage.stageHeight/2);
			addEventListener(MouseEvent.CLICK, click);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		private function addPlayer(x:Number,y:Number):BitmapDataSprite {
			var sprite:BitmapDataSprite = new BitmapDataSprite(world);
			sprite.scaleGap = 0.2;
			sprite.x = x;
			sprite.y = y;
			sprite.addAnimation(up);
			sprite.addAnimation(down);
			sprite.addAnimation(right);
			sprite.addAnimation(left);
			world.add(sprite, false);
			sprite.play("down", 0);
			sprite.update();
			sprite.stop(sprite.currentAnimationName, sprite.frame);
			return sprite;
		}
		
		private function p2p_change(e:Event):void 
		{
			for each(var user:UserObject in p2p.userList) {
				
			}
		}
		
		private function p2p_connect(e:Event):void 
		{
			p2p.addEventListener(PeerStatusEvent.USER_ADDED, p2p_userAdded);
			p2p.addEventListener(PeerStatusEvent.USER_REMOVED, p2p_userRemoved);
			p2p.setReceivePositionCallback(onpos);
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function onpos(peerID:String, position:Object):void 
		{
			var player:Object =  players[peerID];
			if (player) {
				player.tx = position.tx;
				player.a = position.a;
				player.x = position.x;
				player.y = position.y;
			}
			//trace("position");
		}
		
		private function p2p_userRemoved(e:PeerStatusEvent):void 
		{
		}
		
		private function p2p_userAdded(e:PeerStatusEvent):void 
		{
			var sprite:Sprite = addPlayer(465 * Math.random(), 465 * Math.random());
			var player:Object = {sprite:sprite };
			players[e.info.id] = player;
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
		
		private function runPlayer(a:Number, tx:Number, sprite:BitmapDataSprite, x:Number, y:Number):void {
			if (tx != -1) {
				sprite.x = x;
				sprite.y = y;
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
		}
		
		private function enterFrame(e:Event):void 
		{
			if (tx != -1) {
				var speed:Number = 2;
				var a:Number = Math.atan2(ty - sprite.y, tx - sprite.x);
				var x:Number = sprite.x;
				var y:Number = sprite.y;
				if (Math.sqrt((tx-x)*(tx-x)+(ty-y)*(ty-y))<speed) {
					x = tx;
					y = ty;
					tx = -1;
				}else {
					var sx:Number = speed * Math.cos(a);
					var sy:Number = speed * Math.sin(a);
					x += sx;
					y += sy;
				}
				
			}else {
				//sprite.stop(sprite.currentAnimationName, 0);
			}
			runPlayer(a, tx, this.sprite, x, y);
			p2p.sendPosition({a:a,tx:tx,x:x,y:y });
			
			for each(var player:Object in players) {
				a = player.a;
				var tx:Number = player.tx;
				var sprite:BitmapDataSprite = player.sprite;
				x = player.x;
				y = player.y;
				runPlayer(a, tx, sprite, x, y);
			}
			
			world.x = -this.sprite.x + stage.stageWidth / 2;
			world.y = -this.sprite.y + stage.stageHeight / 2;
			world.sortByY();
			var viewport:Rectangle = map.viewport;
			viewport.x = -world.x;
			viewport.y = -world.y;
			map.viewport = viewport;
			map.update();
		}
	}

}