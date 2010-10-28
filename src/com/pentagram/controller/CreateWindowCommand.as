package com.pentagram.controller
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.model.OpenWindowsProxy;
	import com.pentagram.view.components.windows.BaseWindow;
	
	import org.robotlegs.mvcs.Command;
	
	public class CreateWindowCommand extends Command
	{
		[Inject]
		public var openWindowProxy:OpenWindowsProxy;
		
		[Inject]
		public var event:BaseWindowEvent;
		
		override public function execute():void
		{
			var window:BaseWindow;
			
			if (event.uid && openWindowProxy.hasWindowUID(event.uid))
			{
				window = openWindowProxy.getWindowFromUID(event.uid);
			}
			else
			{
				window = openWindowProxy.createWindow(event.uid);
				mediatorMap.createMediator(window);
			}
			
			window.open();
			window.orderToFront();
		}
	}
}