package com.pentagram.controller.configuration
{
	
	import com.pentagram.AppConfigStateConstants;
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureServicesCommand extends Command
	{
		override public function execute():void
		{
			
			//services
			trace("Configure: Services Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_SERVICES_COMPLETE));
		}
	}
}