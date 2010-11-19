package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.InstanceWindowsProxy;
	import com.pentagram.model.OpenWindowsProxy;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureModelsCommand extends Command
	{
		override public function execute():void
		{
			injector.mapSingleton(OpenWindowsProxy);
			injector.mapSingleton(InstanceWindowsProxy);
			injector.mapSingleton(AppModel);
			
			trace("Configure: Models Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_MODELS_COMPLETE));
		}
	}
}