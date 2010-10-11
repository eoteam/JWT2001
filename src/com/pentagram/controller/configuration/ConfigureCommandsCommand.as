package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.controller.startup.StartupCommand;
	import com.pentagram.event.AppEvent;
	
	import mx.states.State;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureCommandsCommand extends Command
	{
		override public function execute():void
		{
			//after login, start sequence FSM
			commandMap.mapEvent(AppEvent.BOOTSTRAP_COMPLETE,StartupCommand,AppEvent);  
			
			trace("Configure: Commands Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_COMMANDS_COMPLETE));
		}
	}
}