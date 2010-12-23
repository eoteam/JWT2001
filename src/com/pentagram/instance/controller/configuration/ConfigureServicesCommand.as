package com.pentagram.instance.controller.configuration
{
	
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.services.DatasetService;
	import com.pentagram.services.ClientService;
	import com.pentagram.services.interfaces.IDatasetService;
	import com.pentagram.services.interfaces.IClientService;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureServicesCommand extends Command
	{
		override public function execute():void
		{
			//services
			injector.mapSingletonOf(IDatasetService, DatasetService);
			injector.mapSingletonOf(IClientService, ClientService);
			trace("Configure Instance: Services Complete");		
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_SERVICES_COMPLETE));
		}
	}
}