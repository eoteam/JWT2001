package com.pentagram.controller
{
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.model.InstanceWindowsProxy;
	
	import mx.core.FlexGlobals;
	
	import org.robotlegs.mvcs.Command;
	
	public class CreateInstanceWindowCommand extends Command
	{
		[Inject]
		public var windowProxy:InstanceWindowsProxy;
		
		[Inject]
		public var event:InstanceWindowEvent;
		
		override public function execute():void
		{
			var window:InstanceWindow;
			
			if (event.uid && windowProxy.hasWindowUID(event.uid))
			{
				window = windowProxy.getWindowFromUID(event.uid);
			}
			else
			{
				window = windowProxy.createWindow();
				//mediatorMap.createMediator(window);
			}
			window.compareArgs = event.args;
			window.appEventDispatcher = FlexGlobals.topLevelApplication.applicationEventDispatcher;
			window.open();
			window.orderToFront();
		}
	}
}