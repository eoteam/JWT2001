package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.model.AppModel;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureModelsCommand extends Command
	{
		override public function execute():void
		{
			injector.mapSingleton(AppModel);
			trace("Configure: Models Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_MODELS_COMPLETE));
		}
	}
}