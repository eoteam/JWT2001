package com.pentagram.view.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.InstanceWindowsProxy;
	import com.pentagram.model.OpenWindowsProxy;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	
	import org.robotlegs.core.IMediator;
	import org.robotlegs.mvcs.Mediator;
	import org.robotlegs.utilities.modular.mvcs.ModuleMediator;
	
	public class MainMediator extends Mediator
	{
		[Inject]
		public var view:Main;
		
		[Inject]
		public var appModel:AppModel;
		
		[Inject]
		public var instanceWindowModel:InstanceWindowsProxy;

		[Inject]
		public var windowModel:OpenWindowsProxy;
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent); 
			eventMap.mapListener(eventDispatcher, InstanceWindowEvent.WINDOW_FOCUS,handleWindowFocus);
			eventMap.mapListener(eventDispatcher, InstanceWindowEvent.WINDOW_CLOSED,handleWindowClosed);
			
			if (NativeApplication.supportsMenu)
			{
				var m:NativeMenu = NativeApplication.nativeApplication.menu;
				var win:NativeMenuItem = m.items[3] as NativeMenuItem;
				var fs:NativeMenuItem = new NativeMenuItem("Full Screen");
				fs.keyEquivalent = "f";
				fs.keyEquivalentModifiers = [Keyboard.COMMAND];
				win.submenu.addItem(fs);			
				fs.addEventListener(Event.SELECT,onItemSelect);	
				
				var newWindow:NativeMenuItem = new NativeMenuItem("New Window");
				win.submenu.addItem(newWindow);			
				newWindow.keyEquivalent = "n";
				newWindow.keyEquivalentModifiers = [Keyboard.COMMAND];
				newWindow.addEventListener(Event.SELECT,handleStartUp);	
				
				var file:NativeMenuItem = m.items[1] as NativeMenuItem;
				appModel.exportMenuItem = new NativeMenuItem("Export SpreadSheet File...");
				appModel.exportMenuItem.addEventListener(Event.SELECT,handleExportSp);
				appModel.exportMenuItem.enabled = false;
				file.submenu.addItemAt(appModel.exportMenuItem,0);	
				var importSp:NativeMenuItem = new NativeMenuItem("Import SpreadSheet...");
				importSp.enabled = false;
				file.submenu.addItemAt(importSp,0);
				
				var arrange:NativeMenuItem = new NativeMenuItem("Arrange");
				m.addItem(arrange);
				var tile:NativeMenuItem = new NativeMenuItem("Tile");
				tile.keyEquivalent = "t";
				tile.keyEquivalentModifiers = [Keyboard.COMMAND];			
				tile.addEventListener(Event.SELECT,handleArrange);
				arrange.submenu = new NativeMenu();
				arrange.submenu.addItem(tile);
				var tile2:NativeMenuItem = new NativeMenuItem("Tile w Fill");
				arrange.submenu.addItem(tile2); 
				tile2.addEventListener(Event.SELECT,handleArrange);
				var cascade:NativeMenuItem = new NativeMenuItem("Cascade");
				arrange.submenu.addItem(cascade);
				cascade.addEventListener(Event.SELECT,handleArrange);
			}
			else if (NativeWindow.supportsMenu)
			{

			}			
			// Manually close all open Windows when app closes.
			view.nativeWindow.addEventListener(Event.CLOSING,onAppWinClose);
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
		// Handle Menu item selection
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
		// Called when application window closes
		protected function onAppWinClose(e:Event):void
		{
			//trace("Handling application window close event");
			closeOpenWindows(e);
		}
		
		// Closes all open windows
		protected function closeOpenWindows(e:Event):void
		{
			// This code can be uncommented to prevent the default close action from occurringand first call the close method on each open window to
			// perform any actions needed. Closes each from most recently opened to oldest.
			//e.preventDefault();
			//for (var i:int = NativeApplication.nativeApplication.openedWindows.length - 1; i>= 0; --i)
			//{
			//NativeWindow(NativeApplication.nativeApplication.openedWindows[i]).close();
			//}
		}
		private function handleStartUp(event:Event):void
		{
			eventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.CREATE_WINDOW));
		
		}
		private function handleWindowClosed(event:Event):void {
			startGCCycle();
		}
		private var gcCount:int;
		private function startGCCycle():void{
			gcCount = 0;
			view.addEventListener(Event.ENTER_FRAME, doGC);
		}
		private function doGC(evt:Event):void{
			flash.system.System.gc();
			if(++gcCount > 1){
				view.removeEventListener(Event.ENTER_FRAME, doGC);
				var timer:Timer = new Timer(40,1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,lastGC);
				timer.start();
			}
		}
		private function lastGC(event:TimerEvent):void{
			System.gc();
		}
	}
}