package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.view.MainView;
	import com.pentagram.view.components.SearchView;
	import com.pentagram.view.mediators.SearchViewMediator;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;
	
	public class ConfigureViewsCommand extends Command
	{
		override public function execute():void
		{
			
			//views
			mediatorMap.mapView(SearchView,	SearchViewMediator); 
			trace("Configure: Views Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_VIEWS_COMPLETE));
		}
	}
}