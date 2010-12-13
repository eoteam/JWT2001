package com.pentagram.instance.controller.configuration
{
	import com.pentagram.events.AppEvent;
	import org.robotlegs.mvcs.Command;
	
	public class StartInstanceCommand extends Command
	{

	
		override public function execute():void
		{
			trace("Instance Started");
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.BOOTSTRAP_COMPLETE));	
		}
	}
}