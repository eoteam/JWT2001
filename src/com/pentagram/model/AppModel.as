package com.pentagram.model
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.User;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.StageDisplayState;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Actor;

	public class AppModel extends Actor
	{
		public function AppModel()
		{
		
		}
	
		[Inject]
		public var instanceWindowModel:InstanceWindowsProxy;
		
		[Bindable]
		public var regions:ArrayList;
		
		[Bindable]
		public var countries:ArrayList;
		
		[Bindable]
		public var clients:ArrayList;
		
		
		public var loggedIn:Boolean = false;
		
		public var user:User;
		

		public var exportMenuItem:NativeMenuItem;
		public var importMenuItem:NativeMenuItem;

		public var windowMenu:NativeMenuItem;
		public var fileMenu:NativeMenuItem;
		
		
		public	function buildMenu():void {
			var arrange:NativeMenuItem = new NativeMenuItem("Arrange");
			arrange.submenu = new NativeMenu();
			
			var tile:NativeMenuItem = new NativeMenuItem("Tile");
			tile.keyEquivalent = "t";
			tile.keyEquivalentModifiers = [Keyboard.COMMAND];			
			tile.addEventListener(Event.SELECT,handleArrange);
			arrange.submenu.addItem(tile);

			var tile2:NativeMenuItem = new NativeMenuItem("Tile w Fill");
			arrange.submenu.addItem(tile2); 
			tile2.addEventListener(Event.SELECT,handleArrange);
			
			var cascade:NativeMenuItem = new NativeMenuItem("Cascade");
			arrange.submenu.addItem(cascade);
			cascade.addEventListener(Event.SELECT,handleArrange);
			
			var newWindow:NativeMenuItem = new NativeMenuItem("New Window");	
			newWindow.keyEquivalent = "n";
			newWindow.keyEquivalentModifiers = [Keyboard.COMMAND];
			newWindow.addEventListener(Event.SELECT,handleStartUp);				
			
			var fullScreen:NativeMenuItem = new NativeMenuItem("Full Screen");
			fullScreen.keyEquivalent 	= "f";
			fullScreen.keyEquivalentModifiers = [Keyboard.COMMAND];			
			fullScreen.addEventListener(Event.SELECT,onItemSelect);
			
			var exportMenuItem:NativeMenuItem = new NativeMenuItem("Export SpreadSheet File...");
			exportMenuItem.addEventListener(Event.SELECT,handleExportSp);
			exportMenuItem.enabled = false;
			
			var importMenuItem:NativeMenuItem = new NativeMenuItem("Import SpreadSheet...");
			importMenuItem.enabled = false;
			
			if (NativeApplication.supportsMenu) {
				var m:NativeMenu = NativeApplication.nativeApplication.menu;
				appModel.windowMenu = m.items[3] as NativeMenuItem;
				appModel.fileMenu = m.items[1] as NativeMenuItem;
				
			}	
			else if(NativeWindow.supportsMenu) {
				appModel.windowMenu = new NativeMenuItem("Window");
				appModel.windowMenu.submenu = new NativeMenu();
				appModel.fileMenu = new NativeMenuItem("File");
				appModel.fileMenu.submenu = new NativeMenu();
			}
			
			appModel.windowMenu.submenu.addItemAt(arrange,0);
			appModel.windowMenu.submenu.addItem(fullScreen);
			appModel.windowMenu.submenu.addItem(newWindow);		
			
			appModel.fileMenu.submenu.addItemAt(appModel.exportMenuItem,0);	
			appModel.fileMenu.submenu.addItemAt(appModel.importMenuItem,0);

		}
		protected function handleArrange(event:Event):void {
			if(event.target.label == "Tile")
				instanceWindowModel.tile(false,10);
			else if(event.target.label == "Tile w Fill")
				instanceWindowModel.tile(true,4);
			else
				instanceWindowModel.cascade();
		}
		protected function handleWindowFocus(event:InstanceWindowEvent):void {
			var window:InstanceWindow = instanceWindowModel.getWindowFromUID(event.uid);
			instanceWindowModel.currentWindow = window;
		}	
		protected function handleStartUp(event:Event):void {
			eventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.CREATE_WINDOW));
		}
		protected function onItemSelect(e:Event):void
		{
			if(instanceWindowModel.currentWindow.stage.displayState == StageDisplayState.NORMAL ) {
				instanceWindowModel.currentWindow.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				instanceWindowModel.currentWindow.showStatusBar = false;
			} 
			else {
				instanceWindowModel.currentWindow.stage.displayState = StageDisplayState.NORMAL;
				instanceWindowModel.currentWindow.showStatusBar = true;
			}
		}
		private function handleExportSp(event:Event):void {
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,windowModel.SPREADSHEET_WINDOW));
		}
	}
}