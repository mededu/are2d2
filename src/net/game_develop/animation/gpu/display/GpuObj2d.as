package net.game_develop.animation.gpu.display 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import net.game_develop.animation.gpu.renders.BasicRenderer;
	import net.game_develop.animation.gpu.renders.IRenderer;
	
	[Event(name="mouseUp", type="flash.events.MouseEvent")] 

	/**
	 * Dispatched when the user moves a pointing device over an InteractiveObject instance.
	 * @eventType	flash.events.MouseEvent.MOUSE_OVER
	 */
	[Event(name="mouseOver", type="flash.events.MouseEvent")] 

	/**
	 * Dispatched when the user moves a pointing device away from an InteractiveObject instance.
	 * @eventType	flash.events.MouseEvent.MOUSE_OUT
	 */
	[Event(name="mouseOut", type="flash.events.MouseEvent")] 

	/**
	 * Dispatched when a user moves the pointing device while it is over an InteractiveObject.
	 * @eventType	flash.events.MouseEvent.MOUSE_MOVE
	 */
	[Event(name="mouseMove", type="flash.events.MouseEvent")] 

	/**
	 * Dispatched when a user presses the pointing device button over an InteractiveObject instance.
	 * @eventType	flash.events.MouseEvent.MOUSE_DOWN
	 */
	[Event(name="mouseDown", type="flash.events.MouseEvent")] 

	/**
	 * Dispatched when a user presses and releases the main button of a pointing device twice in 
	 * rapid succession over the same InteractiveObject when that object's 
	 * doubleClickEnabled flag is set to true.
	 * @eventType	flash.events.MouseEvent.DOUBLE_CLICK
	 */
	[Event(name="doubleClick", type="flash.events.MouseEvent")] 

	/**
	 * Dispatched when a user presses and releases the main button of the user's 
	 * pointing device over the same InteractiveObject.
	 * @eventType	flash.events.MouseEvent.CLICK
	 */
	[Event(name="click", type="flash.events.MouseEvent")] 

	
	/**
	 * gpu显示对象
	 * @author lizhi
	 */
	public class GpuObj2d extends EventDispatcher
	{
		public var parent:GpuObj2d;
		public var childs:Array;
		public var vmatrix:Matrix3D = new Matrix3D;
		public var wmatrix:Matrix3D = new Matrix3D;
		private var _selfMatrix:Matrix3D = new Matrix3D;
		
		public var vouts:Vector.<Number>;
		
		private var _width:Number;
		private var _height:Number;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _rotation:Number = 0;
		
		protected var _change:Boolean = true;
		public var selfChange:Boolean = true;
		
		//private var _texture:UVTexture;
		public var texture:Texture;
		public var textureChange:Boolean = true;
		protected var _bmd:BitmapData;
		public var uv:Point;
		//protected var _view:GpuView2d;
		
		private var _colorTransform:ColorTransform;
		private var colorMulData:Vector.<Number>;
		private var colorAddData:Vector.<Number>;
		public var vertexCode:String;
		public var fragmentCode:String;
		public var program:Program3D;
		public var renderer:IRenderer;
		
		
		public var mouseEnabled:Boolean = true;
		/*public var uvBuffer:VertexBuffer3D;
		public var textureId:int;*/
		
		public var  blendSourceFactor:String = Context3DBlendFactor.ONE;
		public var blendDestinationFactor:String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
		public function GpuObj2d(width:Number=1, height:Number=1,bmd:BitmapData=null,offsetX:Number=NaN, offsetY:Number=NaN,uv:Point=null)
		{
			
			renderer = BasicRenderer.instance;
			_bmd = bmd;
			this.uv = uv;
			_width = width;
			_height = height;
			
			_offsetX = offsetX;
			_offsetY = offsetY;
			
			if (isNaN(offsetX)) 
				_offsetX = -_width / 2;
			else
				_offsetX = offsetX;
			if (isNaN(offsetY))
				_offsetY = -_height / 2;
			else
				_offsetY = offsetY;
			selfMatrix.identity();
			selfMatrix.appendTranslation(_offsetX / _width, -_offsetY / _height, 0);
			selfMatrix.appendScale(_width, _height, 1);
			
			vouts = getVoutFromSelf(selfMatrix);
		}
		
		private static var vins:Vector.<Number> = Vector.<Number>([0, 0, 0, 1, 0, 0, 0, -1, 0, 1, -1, 0]);
		public static function getVoutFromSelf(matr:Matrix3D):Vector.<Number> {
			var vouts:Vector.<Number> = Vector.<Number>([0, 0, 0, 1, 0, 0, 0, -1, 0, 1, -1, 0]);
			matr.transformVectors(vins, vouts);
			return vouts;
		}
		
		/*public function setBmd(bmd:BitmapData, offsetX:Number = NaN, offsetY:Number = NaN):void {
			this.bmd = bmd;
			if(bmd)texture = view.getTexture(bmd);
			if (isNaN(offsetX)) 
				_offsetX = -_width / 2;
			else
				_offsetX = offsetX;
			if (isNaN(offsetY))
				_offsetY = -_height / 2;
			else
				_offsetY = offsetY;
			selfMatrix = new Matrix3D;
			selfMatrix.identity();
			selfMatrix.appendTranslation(_offsetX / _width, -_offsetY / _height, 0);
			selfMatrix.appendScale(_width, _height, 1);
		}*/
		
		public function add(ob2d:GpuObj2d):GpuObj2d {
			if (childs==null) {
				childs = [];
			}
			if (ob2d.parent) {
				ob2d.parent.remove(ob2d);
			}
			childs.push(ob2d);
			ob2d.parent = this;
			
			//if (view) {
			//	addView(ob2d);
			//}
			return ob2d;
		}
		
		/*protected function addView(obj2d:GpuObj2d):void {
			obj2d.view = view;
			if (obj2d.childs) {
				for each(var c:GpuObj2d in obj2d.childs) {
					addView(c);
				}
			}else if (obj2d is GpuSpriteLayer) {
				if ((obj2d as GpuSpriteLayer).layerChilds) {
					for each(c in (obj2d as GpuSpriteLayer).layerChilds) {
						addView(c);
					}
				}
			}
		}*/
		
		public function remove(ob2d:GpuObj2d):GpuObj2d {
			if (childs == null) return null;
			for (var i:int = 0; i < childs.length;i++) {
				var o:GpuObj2d = childs[i];
				if (o == ob2d) {
					childs.splice(i, 1);
					ob2d.parent = null;
					return ob2d;
				}
			}
			return null;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
			change = true;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
			change = true;
		}
		
		
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void
		{
			_scaleX = value;
			change = true;
		}
		
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void
		{
			_scaleY = value;
			change = true;
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void
		{
			_rotation = value;
			change = true;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		public function get offsetX():Number
		{
			return _offsetX;
		}
		
		public function set offsetX(value:Number):void
		{
			_offsetX = value;
		}
		
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
		}
		
		public function get colorTransform():ColorTransform 
		{
			return _colorTransform;
		}
		
		public function set colorTransform(value:ColorTransform):void 
		{
			_colorTransform = value;
			if(_colorTransform){
				colorMulData = Vector.<Number>([value.redMultiplier,value.greenMultiplier,value.blueMultiplier,value.alphaMultiplier]);
				colorAddData = Vector.<Number>([value.redOffset,value.greenOffset,value.blueOffset,value.alphaOffset]);
			}
			//program = view.getProgram(_colorTransform);
		}
		
		public function get bmd():BitmapData 
		{
			return _bmd;
		}
		
		public function set bmd(value:BitmapData):void 
		{
			_bmd = value;
		}
		
		public function get change():Boolean 
		{
			return _change;
		}
		
		public function set change(value:Boolean):void 
		{
			_change = value;
		}
		
		/*public function get texture():UVTexture 
		{
			return _texture;
		}*/
		
		/*public function set texture(value:UVTexture):void 
		{
			if(_texture!=value){
				_texture = value;
				textureChange = true;
			}
		}*/
		
		public function get selfMatrix():Matrix3D 
		{
			return _selfMatrix;
		}
		
		public function set selfMatrix(value:Matrix3D):void 
		{
			//if(_selfMatrix!=value){
				_selfMatrix = value;
				//_selfChange = true;
			//}
		}
		
		/*public function set view(value:GpuView2d):void 
		{
			_view = value;
			trysetView();
		}*/
		
		/*protected function trysetView():void {
			if (_view == null ) return;
			if (_view.c3d) init();
			else _view.addEventListener(Event.CONTEXT3D_CREATE, view_context3dCreate);
		}*/
		
		/*public function get view():GpuView2d 
		{
			return _view;
		}*/
		
		/*private function view_context3dCreate(e:Event):void 
		{
			_view.removeEventListener(Event.CONTEXT3D_CREATE, view_context3dCreate);
			init();
		}*/
			
		
		/*public function init():void {
			setBmd(bmd, _offsetX, _offsetY);
			program = view.getProgram(_colorTransform);
		}*/
		
		
		//private var tempRaw:Vector.<Number> = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]);
		//private var rta:Number = -Math.PI / 180;
		public function recompose():void
		{
			//math
			/*_change = false;
			var a:Number = rta * _rotation;
			var sinT:Number = Math.sin(a);
			var cosT:Number = Math.cos(a);
			tempRaw[0] = cosT * _scaleX;
			tempRaw[1] = sinT * _scaleX;
			tempRaw[4] = -sinT * _scaleY;
			tempRaw[5] = cosT * _scaleY;
			tempRaw[12] = _x;
			tempRaw[13] = -_y;
			vmatrix.rawData = tempRaw;*/
			
			//50000 obj2d
			//cpu 48% fps 21
			_change = false;
			vmatrix.identity();
			vmatrix.appendScale(_scaleX, _scaleY, 1);
			vmatrix.appendRotation( -_rotation, Vector3D.Z_AXIS);
			vmatrix.appendTranslation(_x, -_y,0);
			
			//cpu 50% fps 20
			//vmatrix.recompose();
		}
		
		//public function update():void {
			//if (_colorTransform) {
			//	view.c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colorMulData, 1);
			//	view.c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, colorAddData, 1);
			//}
			//view.c3d.setProgram(program);
		//}
		
		public function sortByY():void {
			if(childs)childs.sortOn("y", Array.NUMERIC);
		}
		public function updateAnimation():void { }
		
		
		/**
		 * Adds a child DisplayObject instance to this DisplayObjectContainer 
		 * instance.  The child is added
		 * at the index position specified. An index of 0 represents the back (bottom) 
		 * of the display list for this DisplayObjectContainer object.
		 * 
		 *   For example, the following example shows three display objects, labeled a, b, and c, at
		 * index positions 0, 2, and 1, respectively:If you add a child object that already has a different display object container as
		 * a parent, the object is removed from the child list of the other display object container.
		 * @param	child	The DisplayObject instance to add as a child of this 
		 *   DisplayObjectContainer instance.
		 * @param	index	The index position to which the child is added. If you specify a 
		 *   currently occupied index position, the child object that exists at that position and all
		 *   higher positions are moved up one position in the child list.
		 * @return	The DisplayObject instance that you pass in the 
		 *   child parameter.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	RangeError Throws if the index position does not exist in the child list.
		 * @throws	ArgumentError Throws if the child is the same as the parent.  Also throws if
		 *   the caller is a child (or grandchild etc.) of the child being added.
		 */
		/*public function addChildAt (child:GpuObj2d, index:int) : GpuObj2d {
			
		}*/

		/**
		 * Indicates whether the security restrictions 
		 * would cause any display objects to be omitted from the list returned by calling
		 * the DisplayObjectContainer.getObjectsUnderPoint() method
		 * with the specified point point. By default, content from one domain cannot 
		 * access objects from another domain unless they are permitted to do so with a call to the 
		 * Security.allowDomain() method. For more information, related to security, 
		 * see the Flash Player Developer Center Topic: 
		 * Security.
		 * 
		 *   The point parameter is in the coordinate space of the Stage, 
		 * which may differ from the coordinate space of the display object container (unless the
		 * display object container is the Stage). You can use the globalToLocal() and 
		 * the localToGlobal() methods to convert points between these coordinate
		 * spaces.
		 * @param	point	The point under which to look.
		 * @return	true if the point contains child display objects with security restrictions.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		//public function areInaccessibleObjectsUnderPoint (point:Point) : Boolean;

		/**
		 * Determines whether the specified display object is a child of the DisplayObjectContainer instance or
		 * the instance itself. 
		 * The search includes the entire display list including this DisplayObjectContainer instance. Grandchildren, 
		 * great-grandchildren, and so on each return true.
		 * @param	child	The child object to test.
		 * @return	true if the child object is a child of the DisplayObjectContainer
		 *   or the container itself; otherwise false.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		//public function contains (child:DisplayObject) : Boolean;


		/**
		 * Returns the child display object instance that exists at the specified index.
		 * @param	index	The index position of the child object.
		 * @return	The child display object at the specified index position.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	RangeError Throws if the index does not exist in the child list.
		 * @throws	SecurityError This child display object belongs to a sandbox
		 *   to which you do not have access. You can avoid this situation by having
		 *   the child movie call Security.allowDomain().
		 */
		//public function getChildAt (index:int) : flash.display.DisplayObject;

		/**
		 * Returns the child display object that exists with the specified name.
		 * If more that one child display object has the specified name, 
		 * the method returns the first object in the child list.
		 * 
		 *   The getChildAt() method is faster than the 
		 * getChildByName() method. The getChildAt() method accesses 
		 * a child from a cached array, whereas the getChildByName() method
		 * has to traverse a linked list to access a child.
		 * @param	name	The name of the child to return.
		 * @return	The child display object with the specified name.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	SecurityError This child display object belongs to a sandbox
		 *   to which you do not have access. You can avoid this situation by having
		 *   the child movie call the Security.allowDomain() method.
		 */
		//public function getChildByName (name:String) : flash.display.DisplayObject;

		/**
		 * Returns the index position of a child DisplayObject instance.
		 * @param	child	The DisplayObject instance to identify.
		 * @return	The index position of the child display object to identify.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	ArgumentError Throws if the child parameter is not a child of this object.
		 */
		//public function getChildIndex (child:DisplayObject) : int;

		/**
		 * Returns an array of objects that lie under the specified point and are children 
		 * (or grandchildren, and so on) of this DisplayObjectContainer instance. Any child objects that
		 * are inaccessible for security reasons are omitted from the returned array. To determine whether 
		 * this security restriction affects the returned array, call the 
		 * areInaccessibleObjectsUnderPoint() method.
		 * 
		 *   The point parameter is in the coordinate space of the Stage, 
		 * which may differ from the coordinate space of the display object container (unless the
		 * display object container is the Stage). You can use the globalToLocal() and 
		 * the localToGlobal() methods to convert points between these coordinate
		 * spaces.
		 * @param	point	The point under which to look.
		 * @return	An array of objects that lie under the specified point and are children 
		 *   (or grandchildren, and so on) of this DisplayObjectContainer instance.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		//public function getObjectsUnderPoint (point:Point) : Array;

		/**
		 * Removes the specified child DisplayObject instance from the child list of the DisplayObjectContainer instance.  
		 * The parent property of the removed child is set to null
		 * , and the object is garbage collected if no other
		 * references to the child exist. The index positions of any display objects above the child in the 
		 * DisplayObjectContainer are decreased by 1.
		 * 
		 *   The garbage collector reallocates unused memory space. When a variable 
		 * or object is no longer actively referenced or stored somewhere, the garbage collector sweeps 
		 * through and wipes out the memory space it used to occupy if no other references to it exist.
		 * @param	child	The DisplayObject instance to remove.
		 * @return	The DisplayObject instance that you pass in the 
		 *   child parameter.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	ArgumentError Throws if the child parameter is not a child of this object.
		 */
		//public function removeChild (child:DisplayObject) : flash.display.DisplayObject;

		/**
		 * Removes a child DisplayObject from the specified index position in the child list of 
		 * the DisplayObjectContainer. The parent property of the removed child is set to 
		 * null, and the object is garbage collected if no other references to the child exist. The index  
		 * positions of any display objects above the child in the DisplayObjectContainer are decreased by 1.
		 * 
		 *   The garbage collector reallocates unused memory space. When a variable or
		 * object is no longer actively referenced or stored somewhere, the garbage collector sweeps 
		 * through and wipes out the memory space it used to occupy if no other references to it exist.
		 * @param	index	The child index of the DisplayObject to remove.
		 * @return	The DisplayObject instance that was removed.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	SecurityError This child display object belongs to a sandbox
		 *   to which the calling object does not have access. You can avoid this situation by having
		 *   the child movie call the Security.allowDomain() method.
		 * @throws	RangeError Throws if the index does not exist in the child list.
		 */
		//public function removeChildAt (index:int) : flash.display.DisplayObject;

		//public function removeChildren (beginIndex:int=0, endIndex:int=2147483647) : void;

		/**
		 * Changes the  position of an existing child in the display object container.
		 * This affects the layering of child objects. For example, the following example shows three 
		 * display objects, labeled a, b, and c, at index positions 0, 1, and 2, respectively:
		 * 
		 *   When you use the setChildIndex() method and specify an index position
		 * that is already occupied, the only positions that change are those in between the display object's former and new position. 
		 * All others will stay the same. 
		 * If a child is moved to an index LOWER than its current index, all children in between will INCREASE by 1 for their index reference.
		 * If a child is moved to an index HIGHER than its current index, all children in between will DECREASE by 1 for their index reference.
		 * For example, if the display object container
		 * in the previous example is named container, you can swap the position 
		 * of the display objects labeled a and b by calling the following code:
		 * <codeblock>
		 * container.setChildIndex(container.getChildAt(1), 0);
		 * </codeblock>
		 * This code results in the following arrangement of objects:
		 * @param	child	The child DisplayObject instance for which you want to change
		 *   the index number.
		 * @param	index	The resulting index number for the child display object.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	RangeError Throws if the index does not exist in the child list.
		 * @throws	ArgumentError Throws if the child parameter is not a child of this object.
		 */
		public function setChildIndex (child:GpuObj2d, index:int) : void {
			var i:int = childs.indexOf(child);
			if (i != -1) childs.splice(index, 0, childs.splice(i, 1)[0]);
		}

		/**
		 * Swaps the z-order (front-to-back order) of the two specified child objects.  All other child 
		 * objects in the display object container remain in the same index positions.
		 * @param	child1	The first child object.
		 * @param	child2	The second child object.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	ArgumentError Throws if either child parameter is not a child of this object.
		 */
		//public function swapChildren (child1:DisplayObject, child2:DisplayObject) : void;

		/**
		 * Swaps the z-order (front-to-back order) of the child objects at the two specified index positions in the 
		 * child list. All other child objects in the display object container remain in the same index positions.
		 * @param	index1	The index position of the first child object.
		 * @param	index2	The index position of the second child object.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	RangeError If either index does not exist in the child list.
		 */
		//public function swapChildrenAt (index1:int, index2:int) : void;
	}

}