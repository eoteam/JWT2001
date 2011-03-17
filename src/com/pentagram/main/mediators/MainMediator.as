package com.pentagram.main.mediators
{
	import com.adobe.serialization.json.JSON;
	import com.darronschall.serialization.ObjectTranslator;
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.InstanceWindowsProxy;
	import com.pentagram.model.OpenWindowsProxy;
	import com.pentagram.model.vo.User;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.System;
	import flash.utils.Timer;
	
	import org.robotlegs.mvcs.Mediator;
	import com.greensock.plugins.*;
	
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
			
			
			TweenPlugin.activate([HexColorsPlugin]);
			TweenPlugin.activate([TransformMatrixPlugin]);
			
			eventMap.mapListener(eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent); 
			eventMap.mapListener(eventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			eventMap.mapListener(eventDispatcher, InstanceWindowEvent.WINDOW_FOCUS,handleWindowFocus);
			eventMap.mapListener(eventDispatcher, InstanceWindowEvent.WINDOW_CLOSED,handleWindowClosed);
			
			if(NativeApplication.supportsMenu) {
				instanceWindowModel.buildMenu();
			}
			// Manually close all open Windows when app closes.
			view.nativeWindow.addEventListener(Event.CLOSING,onAppWinClose);
			view.addEventListener("networkOn",handleNetworkOn);
			
			
			var file:File = File.applicationStorageDirectory;
			file = file.resolvePath("Preferences/user.txt");
			if(file.exists) {
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				var userInfo:String = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
				appModel.user = ObjectTranslator.objectToInstance(JSON.decode(userInfo),User);
				appModel.user.persisted = true;
				eventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGGEDIN,appModel.user));
			}
		}
		private function handleNetworkOn(event:Event):void {
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.STARTUP_BEGIN));
		}
		private function handleWindowFocus(event:InstanceWindowEvent):void {
			
			var window:InstanceWindow = instanceWindowModel.getWindowFromUID(event.uid);
			window.windowFocused = true;
			instanceWindowModel.currentWindow = window;
			for each(var w:InstanceWindow in instanceWindowModel.getAllWindows()) {
				if(w != window)
					w.windowFocused = false;
			}
			
//			if(window.currentState == "visualizer") 
//				instanceWindowModel.toggleToolBars.label = window.shellView.currentState == 'fullScreen'?"Show Tool Bars":"Hide Tool Bars";
		}
		private function handleStartUp(event:Event):void {
			eventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.CREATE_WINDOW));
		}
		// Handle Menu item selection
		private function handleLogin(event:AppEvent):void {
			if(NativeApplication.supportsMenu)
				instanceWindowModel.clientMenuItem.enabled =  instanceWindowModel.userMenuItem.enabled = instanceWindowModel.countriesMenuItem.enabled = true;
			if(!appModel.user.persisted) {
				var userJson:String = event.args[1] as String;
				var file:File = File.applicationStorageDirectory;
				file = file.resolvePath("Preferences/user.txt");
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(userJson.substr(1,userJson.length-2));
				stream.close();
			}
		}

		// Called when application window closes
		private function onAppWinClose(e:Event):void
		{
			//trace("Handling application window close event");
			closeOpenWindows(e);
		}
		
		// Closes all open windows
		private function closeOpenWindows(e:Event):void
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