package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.controller.AuthenticateUserCommand;
	import com.pentagram.controller.CreateDatasetCommand;
	import com.pentagram.controller.CreateWindowCommand;
	import com.pentagram.controller.DeleteDatasetCommand;
	import com.pentagram.controller.LoadClientCommand;
	import com.pentagram.controller.RemoveWindowCommand;
	import com.pentagram.controller.UpdateClientCommand;
	import com.pentagram.controller.startup.StartupCommand;
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.VisualizerEvent;
	
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
			
			commandMap.mapEvent(EditorEvent.UPDATE_CLIENT_DATA,UpdateClientCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.CREATE_DATASET,CreateDatasetCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.DELETE_DATASET,DeleteDatasetCommand,EditorEvent);
			
			//window commands
			commandMap.mapEvent(BaseWindowEvent.CREATE_WINDOW, CreateWindowCommand, BaseWindowEvent );
			commandMap.mapEvent(BaseWindowEvent.WINDOW_CLOSED, RemoveWindowCommand, BaseWindowEvent );  
			trace("Configure: Commands Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_COMMANDS_COMPLETE));
		}
	}
}