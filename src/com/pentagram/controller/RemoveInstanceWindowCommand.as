package com.pentagram.controller
{
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.model.InstanceWindowsProxy;
	
	import org.robotlegs.mvcs.Command;

	public class RemoveInstanceWindowCommand extends Command
	{
		[Inject]
		public var event:InstanceWindowEvent;
		
		[Inject]
		public var openWindowsProxy:InstanceWindowsProxy;
		
		override public function execute():void
		{
			if(openWindowsProxy.hasWindowUID( event.uid ))
				openWindowsProxy.removeWindowByUID( event.uid );
		}
	}
}