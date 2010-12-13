package com.pentagram.instance.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.controller.CreateDatasetCommand;
	import com.pentagram.instance.controller.DeleteDatasetCommand;
	import com.pentagram.instance.controller.LoadClientCommand;
	import com.pentagram.instance.controller.UpdateClientCommand;
	import com.pentagram.instance.controller.UpdateDatasetCommand;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureCommandsCommand extends Command
	{
		override public function execute():void
		{
			//after login, start sequence FSM
			commandMap.mapEvent(VisualizerEvent.CLIENT_SELECTED,LoadClientCommand,VisualizerEvent);
			commandMap.mapEvent(EditorEvent.UPDATE_CLIENT_DATA,UpdateClientCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.CREATE_DATASET,CreateDatasetCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.DELETE_DATASET,DeleteDatasetCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.UPDATE_DATASET,UpdateDatasetCommand,EditorEvent); 
			trace("Configure Instance: Commands Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_COMMANDS_COMPLETE));
		}
	}
}