package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.controller.AuthenticateUserCommand;
	import com.pentagram.controller.LoadClientCommand;
	import com.pentagram.controller.UpdateClientCommand;
	import com.pentagram.controller.startup.StartupCommand;
	import com.pentagram.event.AppEvent;
	import com.pentagram.event.VisualizerEvent;
	
	import mx.states.State;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureCommandsCommand extends Command
	{
		override public function execute():void
		{
			//after login, start sequence FSM
			commandMap.mapEvent(AppEvent.BOOTSTRAP_COMPLETE,StartupCommand,AppEvent); 
			commandMap.mapEvent(AppEvent.LOGIN,AuthenticateUserCommand,AppEvent);  
			
			commandMap.mapEvent(VisualizerEvent.CLIENT_SELECTED,LoadClientCommand,VisualizerEvent);
			commandMap.mapEvent(VisualizerEvent.UPDATE_CLIENT_DATA,UpdateClientCommand,VisualizerEvent);
			
			trace("Configure: Commands Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_COMMANDS_COMPLETE));
		}
	}
}