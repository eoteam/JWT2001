package com.pentagram.controller.configuration
{
	import com.pentagram.events.AppEvent;
	import org.robotlegs.mvcs.Command;
	
	public class StartApplicationCommand extends Command
	{

	
		override public function execute():void
		{
			trace("Application Started");
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.BOOTSTRAP_COMPLETE));	
		}
	}
}