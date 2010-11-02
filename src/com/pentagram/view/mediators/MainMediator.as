package com.pentagram.view.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.model.AppModel;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
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
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent); 
			if (NativeApplication.supportsMenu)
			{
				var m:NativeMenu = NativeApplication.nativeApplication.menu;
				var win:NativeMenuItem = m.items[3] as NativeMenuItem;
				var fs:NativeMenuItem = new NativeMenuItem("Full Screen");
				win.submenu.addItem(fs);			
				fs.addEventListener(Event.SELECT,onItemSelect);	
				
				var newWindow:NativeMenuItem = new NativeMenuItem("New Window");
				win.submenu.addItem(newWindow);			
				newWindow.addEventListener(Event.SELECT,handleStartUp);	
			}
			else if (NativeWindow.supportsMenu)
			{
				//					var menu:NativeMenu = new NativeMenu();
				//					nativeWindow.menu = menu;
				//					item1 = stage.nativeWindow.menu.addItem(new NativeMenuItem("My App Menu"));
				//					item1.addEventListener(Event.SELECT,onItemSelect);
			}
			
			// Manually close all open Windows when app closes.
			view.nativeWindow.addEventListener(Event.CLOSING,onAppWinClose);
		}
		// Handle Menu item selection
		protected function onItemSelect(e:Event):void
		{
			if(view.stage.displayState == StageDisplayState.NORMAL ) {
				view.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				view.showStatusBar = false;
			} 
			else {
				view.stage.displayState = StageDisplayState.NORMAL;
				view.showStatusBar = true;
			}
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
	}
}