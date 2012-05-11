package net.game_develop.animation.utils{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	public class Stats extends Sprite {
		private var xml:XML;
		private var theText:TextField;
		private var fps:int=0;
		private var ms:uint;
		private var lastTimeCheck:uint;
		private var maxMemory:Number=0;
		private var fpsVector:Vector.<Number>=new Vector.<Number>();
		public function Stats():void {
			xml =
			<xml>
			<sectionTitle>ARE2D</sectionTitle>
			<sectionLabel>FPS: </sectionLabel>
			<framesPerSecond>-</framesPerSecond>
			<renderMode>-</renderMode>
			</xml>;
			var style:StyleSheet = new StyleSheet();
			style.setStyle("xml",{fontSize:"9px",fontFamily:"arial"});
			style.setStyle("sectionTitle",{color:"#FFAA00"});
			style.setStyle("sectionLabel",{color:"#CCCCCC",display:"inline"});
			style.setStyle("framesPerSecond",{color:"#FFFFFF"});
			style.setStyle("renderMode",{color:"#FFFFFF"});
			theText = new TextField();
			theText.alpha=0.8;
			theText.autoSize=TextFieldAutoSize.LEFT;
			theText.styleSheet=style;
			theText.condenseWhite=true;
			theText.selectable=false;
			theText.mouseEnabled=false;
			theText.background=true;
			theText.backgroundColor=0x000000;
			addChild(theText);
			addEventListener(Event.ENTER_FRAME, update);
			
			new TitleCore(this, this);
		}
		private function update(e:Event):void {
			var timer:int=getTimer();
			if (timer-1000>lastTimeCheck) {
				var vectorLength:int=fpsVector.push(fps);
				if (vectorLength>60) {
					fpsVector.shift();
				}
				var vectorAverage:Number=0;
				for (var i:Number = 0; i < fpsVector.length; i++) {
					vectorAverage+=fpsVector[i];
				}
				vectorAverage=vectorAverage/fpsVector.length;
				xml.framesPerSecond=fps+" / "+stage.frameRate;
				fps=0;
				lastTimeCheck=timer;
			}
			xml.renderMode = ARE2D.renderMode;
			fps++;
			ms=timer;
			theText.htmlText=xml;
		}
	}
}