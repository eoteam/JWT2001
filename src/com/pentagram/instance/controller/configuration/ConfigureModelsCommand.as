package com.pentagram.instance.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.instance.model.InstanceModel;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureModelsCommand extends Command
	{
		override public function execute():void
		{
			injector.mapSingleton(InstanceModel);
			trace("Configure Instance: Models Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_MODELS_COMPLETE));
		}
	}
}