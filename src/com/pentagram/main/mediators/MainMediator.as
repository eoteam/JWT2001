package com.pentagram.main.mediators
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
		public var view:View;
		
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
			
			if(NativeApplication.supportsMenu) {
				instanceWindowModel.buildMenu();
			}
			// Manually close all open Windows when app closes.
			view.nativeWindow.addEventListener(Event.CLOSING,onAppWinClose);
		}
		protected function handleWindowFocus(event:InstanceWindowEvent):void {
			var window:InstanceWindow = instanceWindowModel.getWindowFromUID(event.uid);
			instanceWindowModel.currentWindow = window;
		}
		protected function handleStartUp(event:Event):void {
			eventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.CREATE_WINDOW));
		}
		// Handle Menu item selection


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