package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.controller.AuthenticateUserCommand;
	import com.pentagram.controller.CreateClientCommand;
	import com.pentagram.controller.CreateCountryCommand;
	import com.pentagram.controller.CreateInstanceWindowCommand;
	import com.pentagram.controller.CreateWindowCommand;
	import com.pentagram.controller.DeleteClientCommand;
	import com.pentagram.controller.DeleteCountryCommand;
	import com.pentagram.controller.InitInstanceCommand;
	import com.pentagram.controller.RemoveInstanceWindowCommand;
	import com.pentagram.controller.RemoveWindowCommand;
	import com.pentagram.controller.UpdateClientCommand;
	import com.pentagram.controller.UpdateCountryCommand;
	import com.pentagram.controller.UserLogoutCommand;
	import com.pentagram.controller.WindowLayoutCommand;
	import com.pentagram.controller.startup.StartupCommand;
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.InstanceWindowEvent;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureCommandsCommand extends Command
	{
		override public function execute():void
		{
			//after login, start sequence FSM
			commandMap.mapEvent(AppEvent.STARTUP_BEGIN,StartupCommand,AppEvent); 
			commandMap.mapEvent(AppEvent.LOGIN,AuthenticateUserCommand,AppEvent);  
			commandMap.mapEvent(AppEvent.LOGGEDOUT,UserLogoutCommand,AppEvent); 
			
			//managers commands
			commandMap.mapEvent(EditorEvent.UPDATE_CLIENT_DATA,UpdateClientCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.CREATE_CLIENT,CreateClientCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.DELETE_CLIENT,DeleteClientCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.UPDATE_COUNTRY,UpdateCountryCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.CREATE_COUNTRY,CreateCountryCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.DELETE_COUNTRY,DeleteCountryCommand,EditorEvent);
			
			//instance commands
			commandMap.mapEvent(InstanceWindowEvent.INIT_INSTANCE, InitInstanceCommand , InstanceWindowEvent );
			
			//window commands
			commandMap.mapEvent(InstanceWindowEvent.CREATE_WINDOW, CreateInstanceWindowCommand , InstanceWindowEvent );
			commandMap.mapEvent(InstanceWindowEvent.WINDOW_CLOSED, RemoveInstanceWindowCommand , InstanceWindowEvent ); 
			commandMap.mapEvent(InstanceWindowEvent.WINDOW_TILE,   WindowLayoutCommand , 		 InstanceWindowEvent ); 
		
			commandMap.mapEvent(BaseWindowEvent.CREATE_WINDOW, CreateWindowCommand, BaseWindowEvent );
			commandMap.mapEvent(BaseWindowEvent.WINDOW_CLOSED, RemoveWindowCommand, BaseWindowEvent );   
			trace("Configure: Commands Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_COMMANDS_COMPLETE));
		}
	}
}