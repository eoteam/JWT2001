package com.pentagram.controller
{
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.events.ViewEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.InstanceWindowsProxy;
	
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	
	import org.robotlegs.mvcs.Command;
	
	public class InitInstanceCommand extends Command
	{
		[Inject]
		public var event:InstanceWindowEvent;
		
		[Inject]
		public var windowModel:InstanceWindowsProxy;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function execute():void {
			var window:InstanceWindow = windowModel.getWindowFromUID(event.uid);
			var callback:Function = event.args[0]; 
			var exp:NativeMenuItem = windowModel.exportMenuItem;
			var imp:NativeMenuItem = windowModel.importMenuItem;
			var tool:NativeMenuItem = windowModel.toolBarMenuItem;
			var image:NativeMenuItem = windowModel.exportImageMenuItem;
			if(NativeWindow.supportsMenu) {
			 	var temp:Array = windowModel.buildMenu(windowModel.getWindowFromUID(event.uid));
				exp = temp[0]; imp = temp[1]; tool = temp[2];
			}
			//var arr:Array = appModel.cloneRegions();
			callback.call(null,
				appModel.clients,appModel.cloneRegions(),appModel.countries,appModel.countryNames,appModel.user,appModel.colors,
				exp,imp,tool,image,
				!NativeWindow.supportsMenu);
			
			if(windowModel.windowMap.size() == 1)
				this.dispatch(new InstanceWindowEvent(InstanceWindowEvent.FIRST_WINDOW_CREATED));
		}
	}
}