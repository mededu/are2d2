package net.game_develop.animation.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ARE2D 
	{
		public static const name:String="ARE2D";
		public static const url:String="http://code.google.com/p/animation-render-engine/";
		public static var renderMode:String = "";
		public static function addMenu(dis:DisplayObjectContainer):void {
			try{
			var troot:DisplayObjectContainer=dis;
			while (troot.parent&&!(troot.parent is Stage)) troot = troot.parent;
			var menu:ContextMenu = new ContextMenu();
			var item:ContextMenuItem = new ContextMenuItem("powered by "+name);
			menu.customItems.push(item);
			troot.contextMenu = menu;
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, item_menuItemSelect);}catch(err:*){}
		}
		
		static private function item_menuItemSelect(e:ContextMenuEvent):void 
		{
			navigateToURL(new URLRequest(url),"_block")
		}
	}

}