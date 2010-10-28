package com.pentagram.controller
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.model.OpenWindowsProxy;
	
	import org.robotlegs.mvcs.Command;

	public class RemoveWindowCommand extends Command
	{
		[Inject]
		public var event:BaseWindowEvent;
		
		[Inject]
		public var openWindowsProxy:OpenWindowsProxy;
		
		override public function execute():void
		{
			if(openWindowsProxy.hasWindowUID( event.uid ))
				openWindowsProxy.removeWindowByUID( event.uid );
		}
	}
}