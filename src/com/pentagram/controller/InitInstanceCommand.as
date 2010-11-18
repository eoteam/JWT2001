package com.pentagram.controller
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.InstanceWindowsProxy;
	import com.pentagram.model.OpenWindowsProxy;
	
	import mx.core.FlexGlobals;
	
	import org.robotlegs.mvcs.Command;
	
	public class InitInstanceCommand extends Command
	{
		[Inject]
		public var event:InstanceWindowEvent;
		
		[Inject]
		public var windowModel:InstanceWindowsProxy;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function execute():void
		{
			var window:InstanceWindow = windowModel.getWindowFromUID(event.uid);
			var callback:Function = event.args[0]; 
			callback.call(null,appModel.clients,appModel.regions,appModel.countries,appModel.user,
				appModel.exportMenuItem,appModel.importMenuItem,appModel.fileMenu,appModel.windowMenu);
		}
	}
}