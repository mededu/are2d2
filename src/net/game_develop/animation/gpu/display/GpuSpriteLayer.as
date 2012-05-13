package net.game_develop.animation.gpu.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import net.game_develop.animation.gpu.GpuView2d;
	import net.game_develop.animation.gpu.progroms.ProgromManager;
	import net.game_develop.animation.gpu.renders.LayerRenderer;
	import net.game_develop.animation.gpu.textures.TextureManager;
	import net.game_develop.animation.utils.InsertBox;
	
	/**
	 * ...
	 * 记录未优化前 15000 fps34-35
	 * 
	 * 
	 * 加入  伴随着加入物体的本身改变 重新创建顶点buff uvbuff 是否有新bmd，加入新贴图
	 * 删除  剔除顶点uv数组的数据 重新创建顶点buff uvbuff 暂时不剔除贴图，提供重置贴图的函数
	 * 改变xyz角度拉伸 本身改变，执行计算顶点
	 * 父改变 本身改变计算顶点
	 * 贴图uv改变 计算uv
	 * 由于播放动画导致内部改变 计算uv
	 * @author lizhi
	 */
	public class GpuSpriteLayer extends GpuObj2d
	{
		static private var toRADIANS :Number = Math.PI/180;
		
		internal var _vertexData:Vector.<Number>;
		internal var _indexData:Vector.<uint>;
		internal var _uvData:Vector.<Number>;
		
		protected var _indexBuffer:IndexBuffer3D;
		protected var _vertexBuffer:VertexBuffer3D;
		protected var _uvBuffer:VertexBuffer3D;
		protected var _shaderProgram:Program3D;
		private var vlChange:Boolean = true;//buff长度改变
		private var vChange:Boolean = true;//v数据改变
		private var uvChange:Boolean = true;//uv数据改变
		private var tchange:Boolean = true;//材质改变
		
		private var vw2:Number;
		private var vh2:Number;
		private var vtx:Number;
		private var vty:Number;
		
		private var insertBox:InsertBox = new InsertBox(2048, 2048);
		private var insertbmd:BitmapData = new BitmapData(2048, 2048, true, 0);
		private var inserttexture:Texture;
		private var rects:Dictionary = new Dictionary;
		private var objindexs:Dictionary = new Dictionary;
		
		
		public function GpuSpriteLayer(view:GpuView2d,numChilds:int=15000)
		{
			this.view = view;
			this.numChilds = numChilds;
			vlChange = true;
			
			_vertexData = new Vector.<Number>();
			_indexData = new Vector.<uint>();
			_uvData = new Vector.<Number>();
			
			for (var i:int = 0; i < numChilds;i++ ) {
				_vertexData.push(0, 0, 0, 1, 0, 0, 0, -1, 0, 1, -1, 0);
				_uvData.push(0, 0, 1, 0, 0, 1, 1, 1);
				var count:int = i * 4;
				_indexData.push(count, count + 1, count + 3, count + 3, count + 2, count);
			}
			super(1, 1, null);
			renderer = LayerRenderer.instance;
			view.addEventListener(Event.RESIZE, view_resize);
			vertexCode ="mov op,va0\n" +
					"mov v0,va1";
			fragmentCode="tex ft0, v0, fs0 <2d,linear,nomip>\n"+
					"mov oc,ft0";
		}
		
		private function view_resize(e:Event):void 
		{
			if (childs == null) return;
			for each(var obj:GpuObj2d in childs) {
				obj.change = true;
			}
		}
		
		override public function recompose():void
		{
			super.recompose();
			var tvw2:Number = /*scaleX**/2 / view.viewWidth;
			var tvh2:Number = /*scaleY**/2 / view.viewHeight;
			
			var tvtx:Number = 1-wmatrix.position.x*tvw2;// v2.x;// -matr.rawData[3];
			var tvty:Number = 1 + wmatrix.position.y * tvh2;// v2.y;// matr.rawData[7];
			if (tvw2 != vw2 || tvh2 != vh2 || tvtx != vtx || tvty != vty) {
				vw2 = tvw2;
				vh2 = tvh2;
				vtx = tvtx;
				vty = tvty;
				for each(var obj:GpuObj2d in childs) {
					obj.change = true;
				}
			}
			
		}
		
		override public function update():void
		{
			//ver 2 uv 1 tex 0 index
			if (childs&&childs.length>0)
			{
				recompose();
				wmatrix.rawData = vmatrix.rawData;
				if (parent) {
					wmatrix.append(parent.wmatrix);
				}
				recompose();
				//var time:int = getTimer();
				//trace("recompose",getTimer()-time);
				//time = getTimer();
				for (var i:int = 0, len:int = childs.length; i < len; i++)
				{
					//updateChildVertexDate;
					
					var ob2d:GpuObj2d = childs[i];
					ob2d.updateAnimation();
					
					// TODO : selfChange
					//use math  12000 fps 55
					if (ob2d.change||ob2d.selfChange) {
						ob2d.change = false;
						ob2d.selfChange = false;
						vChange = true;
						var sinT:Number = Math.sin(-ob2d.rotation * toRADIANS);
						var cosT:Number = Math.cos(-ob2d.rotation * toRADIANS);
						var count:int = i * 12;
						_vertexData[count] =      (ob2d.vouts[0]*ob2d.scaleX * cosT - ob2d.vouts[1] * ob2d.scaleY* sinT + ob2d.x) * vw2 - vtx;
						_vertexData[count + 1] = -( -ob2d.vouts[1] * ob2d.scaleY * cosT - ob2d.vouts[0] * ob2d.scaleX * sinT + ob2d.y) * vh2 + vty;
						
						_vertexData[count+3] =      (ob2d.vouts[3]*ob2d.scaleX * cosT - ob2d.vouts[4] * ob2d.scaleY* sinT + ob2d.x) * vw2 - vtx;
						_vertexData[count + 4] = -( -ob2d.vouts[4] * ob2d.scaleY * cosT - ob2d.vouts[3] * ob2d.scaleX * sinT + ob2d.y) * vh2 + vty;
						
						_vertexData[count+6] =      (ob2d.vouts[6]*ob2d.scaleX * cosT - ob2d.vouts[7] * ob2d.scaleY* sinT + ob2d.x) * vw2 - vtx;
						_vertexData[count + 7] = -( -ob2d.vouts[7] * ob2d.scaleY * cosT - ob2d.vouts[6] * ob2d.scaleX * sinT + ob2d.y) * vh2 + vty;
						
						_vertexData[count+9] =      (ob2d.vouts[9]*ob2d.scaleX * cosT - ob2d.vouts[10] * ob2d.scaleY* sinT + ob2d.x) * vw2 - vtx;
						_vertexData[count + 10] = -(-ob2d.vouts[10]*ob2d.scaleY * cosT - ob2d.vouts[9] *ob2d.scaleX* sinT + ob2d.y) * vh2 + vty;
					}
					 
					if (ob2d.textureChange) {
						ob2d.textureChange = false;
						
						var irect:Rectangle = rects[ob2d.bmd];
						if(irect){
							var tcount:int = 8 * i;
							_uvData[tcount]=_uvData[tcount+4] = irect.x / 2048;
							_uvData[tcount + 1]=_uvData[tcount+3] = irect.y / 2048;
							_uvData[tcount+2]=_uvData[tcount+6] = irect.right / 2048;
							_uvData[tcount + 5] = _uvData[tcount + 7] = irect.bottom / 2048;
							uvChange = true;
						}
					}
				}
				
				
				//trace("childs",getTimer()-time);
				//time = getTimer();
				view.c3d.setBlendFactors(blendSourceFactor, blendDestinationFactor);
				if (program == null) program = ProgromManager.instance.getProgrom(vertexCode, fragmentCode,view.c3d);
				view.c3d.setProgram(program);
				
				if (tchange) {
					var t:Texture = TextureManager.instance.lib[insertbmd];
					if (t) {
						t.dispose();
						TextureManager.instance.lib[insertbmd] = null;
						delete TextureManager.instance.lib[insertbmd];
					}
					inserttexture = TextureManager.instance.getTexture(insertbmd, view.c3d);//view.textures[view.getTexture(insertbmd,true).textureId];
					tchange = false;
				}
				view.c3d.setTextureAt(0, inserttexture);
				
				
				//race("settexture",getTimer()-time);
				//time = getTimer();
				
				if (vlChange)
				{
					if (_vertexBuffer)
						_vertexBuffer.dispose();
					if (_uvBuffer)
						_uvBuffer.dispose();
					if (_indexBuffer)
						_indexBuffer.dispose();
					_vertexBuffer = view.c3d.createVertexBuffer(_vertexData.length / 3, 3);
					_indexBuffer = view.c3d.createIndexBuffer(_indexData.length);
					_uvBuffer = view.c3d.createVertexBuffer(_uvData.length / 2, 2);
					_indexBuffer.uploadFromVector(_indexData, 0, _indexData.length);
					vlChange = false;
				}
				
				//trace("vlchange",getTimer()-time);
				//time = getTimer();
				
				if (uvChange) {
					_uvBuffer.uploadFromVector(_uvData, 0,  _uvData.length / 2);
					uvChange = false;
				}
				
				
				//trace("uvchange",getTimer()-time);
				//time = getTimer();
				if (vChange) {
					_vertexBuffer.uploadFromVector(_vertexData, 0, _vertexData.length / 3);
					vChange = false;
				}
				
				
				//trace("vchange",getTimer()-time);
				//time = getTimer();
				view.c3d.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
				view.c3d.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				
				view.c3d.drawTriangles(_indexBuffer, 0, childs.length * 2);
				
				
				//trace("draw",getTimer()-time);
				//time = getTimer();
				
			}
		}
		
		/**
		 * 执行插入child的更新位图材质操作
		 * @param	ob2d
		 */
		public function updateInsert(ob2d:GpuObj2d):void {
			//trace("updateInsert");
			if (ob2d is GpuAnimationSprite) {
				var aob2d:GpuAnimationSprite = ob2d as GpuAnimationSprite;
				for each(var adata:GpuAnimationData in aob2d.animations) {
					for each(var abase:GpuAnimationBase in adata.textures) {
						var irect:Rectangle = rects[abase.bmd];
						if (abase.bmd&&irect==null) {
							if (insertBox.add(abase.bmd.rect)) {
								irect = insertBox.boxs[insertBox.boxs.length - 1];
								insertbmd.setVector(irect, abase.bmd.getVector(abase.bmd.rect));
								rects[abase.bmd] = irect;
								tchange = true;
							}else {
								throw "gpuspritelayer 位图大小超过2048";
							}
						}
					}
				}
			}else {
				irect = rects[ob2d.bmd];
				if (ob2d.bmd&&irect==null) {
					if (insertBox.add(ob2d.bmd.rect)) {
						irect = insertBox.boxs[insertBox.boxs.length - 1];
						insertbmd.setVector(irect, ob2d.bmd.getVector(ob2d.bmd.rect));
						rects[ob2d.bmd] = irect;
						tchange = true;
					}else {
						throw "gpuspritelayer 位图大小超过2048";
					}
				}
			}
			
			if (irect == null) irect = testirect;
			
			uvChange = true;
		}
		private var testirect:Rectangle = new Rectangle;
		
		//重现刷新插入材质
		public function resetInserts():void {
			insertBox.clear();
			insertbmd.fillRect(insertbmd.rect, 0);
			rects = new Dictionary;
			for (var i:int = 0,len:int = childs.length; i < len; i++)
			{
				var ob2d:GpuObj2d = childs[i]; 
				updateInsert(ob2d);
			}
			tchange = true;
		}
		private var numChilds:int;
		private var view:GpuView2d;
		private var vins:Vector.<Number> = Vector.<Number>([0, 0, 0, 1, 0, 0, 0, -1, 0, 1, -1, 0]);
		override public function add(ob2d:GpuObj2d):GpuObj2d
		{
			if (childs == null)
			{
				childs = [];
				resetInserts();
			}
			
			if (ob2d.parent)
			{
				ob2d.parent.remove(ob2d);
			}
			objindexs[ob2d] = childs.length;
			var count:int = 12 * childs.length;
			childs.push(ob2d);
			ob2d.parent = this;
			
			vChange = true;
			updateInsert(ob2d);
			
			return ob2d;
		}
		
		override public function remove(ob2d:GpuObj2d):GpuObj2d
		{
			if (childs == null)
				return null;
			var i:int = objindexs[ob2d];
			objindexs[ob2d] = null;
			delete objindexs[ob2d];
			ob2d.parent = null;
			childs.splice(i, 1);
			_vertexData.splice(i*12, 12);
			_vertexData.push(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			_uvData.splice(i * 8, 8);
			_uvData.push(0, 0, 0, 0, 0, 0, 0, 0);
			for (var len:int=childs.length; i < len;i++ ) {
				var obj:GpuObj2d = childs[i];
				objindexs[obj] = i;
			}
			vChange = true;
			uvChange = true;
			return null;
		}
		
		override public function set change(value:Boolean):void 
		{
			if (value) {
				for each(var obj2d:GpuObj2d in childs) {
					obj2d.change = true;
				}
			}
			_change = value;
		}
		
		override public function setChildIndex (child:GpuObj2d, index:int) : void {
			var i:int = childs.indexOf(child);
			if (i != -1) {
				objindexs[child] = index;
				childs.splice(index, 0, childs.splice(i, 1)[0]);
				if (i != index) {
					var c:int = i * 12;
					var v0:Number = _vertexData[c];
					var v1:Number = _vertexData[c + 1];
					var v3:Number = _vertexData[c + 3];
					var v4:Number = _vertexData[c + 4];
					var v6:Number = _vertexData[c + 6];
					var v7:Number = _vertexData[c + 7];
					var v9:Number = _vertexData[c + 9];
					var v10:Number = _vertexData[c + 10];
					c = i * 8;
					var uv0:Number = _uvData[c];
					var uv1:Number = _uvData[c + 1];
					var uv2:Number = _uvData[c + 2];
					var uv3:Number = _uvData[c + 3];
					var uv4:Number = _uvData[c + 4];
					var uv5:Number = _uvData[c + 5];
					var uv6:Number = _uvData[c + 6];
					var uv7:Number = _uvData[c + 7];
					if(i<index){
						for (var j:int = i; j < index; j++ ) {
							objindexs[childs[j]] = j;
							c = j * 12;
							_vertexData[c] = _vertexData[c + 12];
							_vertexData[c + 1] = _vertexData[c + 13];
							_vertexData[c + 3] = _vertexData[c + 15];
							_vertexData[c + 4] = _vertexData[c + 16];
							_vertexData[c + 6] = _vertexData[c + 18];
							_vertexData[c + 7] = _vertexData[c + 19];
							_vertexData[c + 9] = _vertexData[c + 21];
							_vertexData[c + 10] = _vertexData[c + 22];
							c = j * 8;
							_uvData[c] = _uvData[c + 8];
							_uvData[c + 1] = _uvData[c + 9];
							_uvData[c + 2] = _uvData[c + 10];
							_uvData[c + 3] = _uvData[c + 11];
							_uvData[c + 4] = _uvData[c + 12];
							_uvData[c + 5] = _uvData[c + 13];
							_uvData[c + 6] = _uvData[c + 14];
							_uvData[c + 7] = _uvData[c + 15];
						}
					}else {
						for (j = i; j > index;j-- ) {
							objindexs[childs[j]] = j;
							c = j * 12;
							_vertexData[c] = _vertexData[c - 12];
							_vertexData[c + 1] = _vertexData[c - 11];
							_vertexData[c + 3] = _vertexData[c - 9];
							_vertexData[c + 4] = _vertexData[c - 8];
							_vertexData[c + 6] = _vertexData[c - 6];
							_vertexData[c + 7] = _vertexData[c - 5];
							_vertexData[c + 9] = _vertexData[c - 3];
							_vertexData[c + 10] = _vertexData[c - 2];
							
							
							c = j * 8;
							_uvData[c] = _uvData[c - 8];
							_uvData[c + 1] = _uvData[c + 7];
							_uvData[c + 2] = _uvData[c + 6];
							_uvData[c + 3] = _uvData[c + 5];
							_uvData[c + 4] = _uvData[c + 4];
							_uvData[c + 5] = _uvData[c + 3];
							_uvData[c + 6] = _uvData[c + 2];
							_uvData[c + 7] = _uvData[c + 1];
						}

					}
					c = index * 12;
					_vertexData[c] = v0;
					_vertexData[c + 1] = v1;
					_vertexData[c + 3] = v3;
					_vertexData[c + 4] = v4;
					_vertexData[c + 6] = v6;
					_vertexData[c + 7] = v7;
					_vertexData[c + 9] = v9;
					_vertexData[c + 10] = v10;
					c = index * 8;
					_uvData[c] = uv0;
					_uvData[c + 1] = uv1;
					_uvData[c + 2] = uv2;
					_uvData[c + 3] = uv3;
					_uvData[c + 4] = uv4;
					_uvData[c + 5] = uv5;
					_uvData[c + 6] = uv6;
					_uvData[c + 7] = uv7;
					
				}
				vChange = true;
				uvChange = true;
			}
		}
		
		override public function sortByY():void {
			if (childs == null) return;
			childs.sortOn("y", Array.NUMERIC);
			
			for (var i:int = 0, len:int = childs.length; i < len;i++ ) {
				var obj:GpuObj2d = childs[i];
				objindexs[obj] = i;
				obj.change = true;
				obj.textureChange = true;
			}
		}
	}

}