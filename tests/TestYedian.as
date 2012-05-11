package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import net.game_develop.animation.gpu.GpuAnimationData;
	import net.game_develop.animation.gpu.GpuAnimationParser;
	import net.game_develop.animation.gpu.GpuAnimationSprite;
	import net.game_develop.animation.gpu.GpuObj2d;
	import net.game_develop.animation.gpu.GpuSpriteLayer;
	import net.game_develop.animation.gpu.GpuView2d;
	import net.game_develop.animation.utils.Stats;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestYedian extends Sprite
	{
		private var dir:Dictionary = new Dictionary;
		private var aarr:Array = [];
		private var count:int = 0;
		private var garr:Array = [];
		private var view:GpuView2d;
		private var players:Array = [];
		private var main:GpuObj2d;
		private var groundLayer:GpuObj2d;
		private var layer:GpuObj2d;
		
		private var tf:TextField;
		private var tx:int = -1;
		private var ty:int = -1;
		private var sprite:Particle;
		private var particles:Array=[];
		public function TestYedian() 
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			view = new GpuView2d(stage.stageWidth, stage.stageHeight);
			addChild(view);
			//layer = new GpuObj2d;
			main = new GpuObj2d;
			view.add(main);
			groundLayer = new GpuSpriteLayer;
			
			main.add(groundLayer);
			layer = new  GpuSpriteLayer;
			main.add(layer);
			
			[Embed(source = "yedian", mimeType = "application/octet-stream")]var c:Class;
			var ba:ByteArray = new c as ByteArray;
			var obj:Object = ba.readObject();
			for each(var arr:Array in obj) {
				var barr:Array = [];
				aarr.push(barr);
				
				for (var i:int = 0; i < 3; i++ ) {
					if (i == 0) var arr2:Array = arr["walk_1"];
					else if (i == 1) arr2 = arr["walk_2"];
					else arr2=arr["dance_a_1"]
					var carr:Array = [];
					barr.push(carr);
					count++;
					var loader:Loader = new Loader;
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
					dir[loader] = carr;
					carr[1] = arr2[1];
					loader.loadBytes(arr2[0]);
				}
			}
			
			addChild(new Stats);
			tf = new TextField;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.background = true;
			tf.backgroundColor = 0xffffff;
			addChild(tf);
			tf.selectable = tf.mouseWheelEnabled = false;
			tf.x = 100;
			
			stage.addEventListener(Event.RESIZE, resize);
		}
		
		private var gw:int;
		private var gh:int;
		private function initGround():void 
		{
			[Embed(source = "g_lea2.png")]var bg0:Class;
			var bmd0:BitmapData = (new bg0 as Bitmap).bitmapData;
			[Embed(source = "g_lea7.png")]var bg1:Class;
			var bmd1:BitmapData = (new bg1 as Bitmap).bitmapData;
			[Embed(source = "g_snow.png")]var bg2:Class;
			var bmd2:BitmapData = (new bg2 as Bitmap).bitmapData;
			[Embed(source="g_stone1.png")]var bg3:Class;
			var bmd3:BitmapData = (new bg3 as Bitmap).bitmapData;
			
			var bmds:Array = [bmd0, bmd1, bmd2, bmd3];
			(groundLayer as GpuSpriteLayer).layerChilds = [];
			gw = Math.ceil(stage.stageWidth / 96) + 1;
			gh = Math.ceil(stage.stageHeight / 96) + 1;
			for (var x:int = 0; x < gw;x++ ) {
				for (var y:int = 0; y < gh;y++ ) {
					var obj2d:GpuObj2d = new GpuObj2d(96, 96, bmds[int(bmds.length * Math.random())]);
					obj2d.x = 96 * x;
					obj2d.y = 96 * y;
					groundLayer.add(obj2d);
				}
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
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
			tx = -main.x+mouseX;
			ty = -main.y+mouseY
		}
		
		private function update():void
		{
			for each(var s:Particle in particles){
				if(!s.isDance){s.x += s.vx;
				s.y += s.vy;
				}
				var flag:Boolean = false;
				if (s.x < -main.x)
				{
					s.vx = Math.abs(s.vx);
					flag = true;
				}else if (s.x > -main.x+stage.stageWidth)
				{
					s.vx = -Math.abs(s.vx);
					flag = true;
				}
				
				if (s.y < -main.y)
				{
					s.vy = Math.abs(s.vy);
					flag = true;
				}else if (s.y >-main.y+ stage.stageHeight)
				{
					s.vy = -Math.abs(s.vy);
					flag = true;
				}
				
				if (flag) {
					var a:Number = Math.atan2(s.vy, s.vx);
					s.a = a;
					s.isDance = false;
				}else {
					if (Math.random()<0.01) {
						s.play("dc", s.frame);
						s.isDance = true;
					}
					if (s.isDance&&Math.random()<0.01) {
						s.isDance = false;
						s.a = Math.atan2(s.vy, s.vx);
					}
				}
			}
			layer.sortByY();
		}
		
		private function enterFrame(e:Event):void 
		{
			update();
			if (tx != -1) {
				var speed:Number = 5;
				var a:Number = Math.atan2(ty - sprite.y, tx - sprite.x);
				sprite.a = a;
				if (Math.sqrt((tx-sprite.x)*(tx-sprite.x)+(ty-sprite.y)*(ty-sprite.y))<speed) {
					sprite.x = tx;
					sprite.y = ty;
					tx = -1;
					sprite.play("dc", sprite.frame);
				}else {
					var sx:Number = speed * Math.cos(a);
					var sy:Number = speed * Math.sin(a);
					sprite.x += sx;
					sprite.y += sy;
				}
			}
			main.x = int(-sprite.x + stage.stageWidth / 2);
			main.y = int( -sprite.y + stage.stageHeight / 2);
			for each(var obj2d:GpuObj2d in (groundLayer as GpuSpriteLayer).layerChilds) {
				var x:Number = main.x + obj2d.x;
				if (x<-48) {
					x += Math.ceil( -x / gw/96)*gw*96;
					obj2d.x = x - main.x;
				}else if(x>(stage.stageWidth+48)){
					x -= Math.max(1,Math.ceil((x - gw * 96) / gw / 96)) * gw * 96;
					obj2d.x = x - main.x;
				}
				var y:Number = main.y + obj2d.y;
				if (y<-48) {
					y += Math.ceil( -y / gh/96)*gh*96;
					obj2d.y = y - main.y;
				}else if(y>(stage.stageHeight+48)){
					y -= Math.max(1,Math.ceil((y - gh * 96) / gh / 96)) * gh * 96;
					obj2d.y = y - main.y;
				}
			}
		}
		
		private function resize(e:Event):void 
		{
			trace(stage.stageWidth, stage.stageHeight);
			
			view.viewWidth = stage.stageWidth;
			view.viewHeight = stage.stageHeight;
			initGround();
		}
		
		private function loader_complete(e:Event):void 
		{
			dir[(e.currentTarget as LoaderInfo).loader][0] = ((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData;
			
			count--;
			if (count <= 0) {
				for (var i:int = 0; i < aarr.length;i++ ) {
					garr[i] = [];
					garr[i][0] = getGpuAni(aarr[i][0][0],aarr[i][0][1],"ld");
					garr[i][1] = getGpuAni(aarr[i][1][0], aarr[i][1][1], "lu");
					garr[i][2] = getGpuAni(aarr[i][2][0], aarr[i][2][1], "dc");
				}
			add(100);
			initGround();
			sprite = randPlayer(true);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			tf.addEventListener(MouseEvent.CLICK, tf_click);
			}
			
		}
		
		private function tf_click(e:MouseEvent):void 
		{
			add(100);
		}
		
		private function add(num:int):void {
				while (num-->0) {
					randPlayer();
				}
				layer.sortByY();
			tf.text = "点击增加动画数量" + (layer as GpuSpriteLayer).layerChilds.length;
		}
		
		private function randPlayer(isme:Boolean = false):Particle {
			var sprite:Particle = new Particle;
			var ran:int = int(garr.length * Math.random());
			sprite.addAnimation(garr[ran][0]);
			sprite.addAnimation(garr[ran][1]);
			sprite.addAnimation(garr[ran][2]);
			sprite.play("ld",100*Math.random());
			layer.add(sprite);
			sprite.x = view.viewWidth * Math.random();
			sprite.y = view.viewHeight * Math.random();
			sprite.vx = (Math.random() - Math.random()) * 3;
                sprite.vy = (Math.random() - Math.random()) * 3;
			sprite.scaleGap = Math.sqrt(sprite.vx * sprite.vx + sprite.vy * sprite.vy)/8;
				if (!isme) particles.push(sprite);
				return sprite;
		}
		
		private function getGpuAni(asset:BitmapData, con:ByteArray,name:String):GpuAnimationData {
			con.endian = Endian.LITTLE_ENDIAN;
			//loc8
			//hotx
			//hoty
			//numframes
			//    delay
			//    stay
			//    offsetX
			//    offsetY
			//    width
			//    height
			//    posX
			//    posY
			con.readInt();
			var hotX:int = con.readInt();
			var hotY:int = con.readInt();
			var numFrames:int = con.readInt();
			var bmds:Vector.<BitmapData> = new Vector.<BitmapData>;
			var offsets:Vector.<Point> = new Vector.<Point>;
			while (numFrames-->0) {
				var delay:int = con.readInt();
				var stay:int = con.readInt();
				var offsetX:int = con.readInt();
				var offsetY:int = con.readInt();
				var widht:int = con.readInt();
				var height:int = con.readInt();
				var px:int = con.readInt();
				var py:int = con.readInt();
				var bmd:BitmapData = new BitmapData(widht, height);
				bmd.setVector(bmd.rect, asset.getVector(new Rectangle(px, py, widht, height)));
				bmds.push(bmd);
				offsets.push(new Point(offsetX-hotX, offsetY-hotY));
			}
			
			return GpuAnimationParser.parser(bmds, offsets, name);
		}
	}

}

import net.game_develop.animation.gpu.GpuAnimationSprite;

class Particle extends GpuAnimationSprite
{
	public var vx:Number;
	public var vy:Number;
	
	public var isDance:Boolean = false;
	public function Particle()
	{
		super();
	}
	
	public function set a(a:Number):void {
		if (a<-Math.PI/2) {
			scaleX = 1;
			play("lu", frame);
		}else if (a<0) {
			scaleX = -1;
			play("lu", frame);
		}else if (a < Math.PI / 2) {
			scaleX = -1;
			play("ld", frame);
		}else {
			scaleX = 1;
			play("ld", frame);
		}
	}
}