package com.pentagram.controller.configuration
{
	
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.services.AppService;
	import com.pentagram.services.ClientService;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.services.interfaces.IClientService;

	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureServicesCommand extends Command
	{
		override public function execute():void
		{
			//services
			trace("Configure: Services Complete");
			injector.mapSingletonOf(IAppService, AppService); 
			injector.mapSingletonOf(IClientService, ClientService);
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_SERVICES_COMPLETE));
		}
	}
}