package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.view.MainView;
	import com.pentagram.view.components.BottomBarView;
	import com.pentagram.view.components.ClientBarView;
	import com.pentagram.view.components.SearchView;
	import com.pentagram.view.mediators.BottomBarMediator;
	import com.pentagram.view.mediators.ClientBarMediator;
	import com.pentagram.view.mediators.MainViewMediator;
	import com.pentagram.view.mediators.SearchViewMediator;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;
	
	public class ConfigureViewsCommand extends Command
	{
		override public function execute():void
		{
			
			//views
			mediatorMap.mapView(SearchView,	SearchViewMediator); 
			mediatorMap.mapView(MainView, MainViewMediator);
			mediatorMap.mapView(BottomBarView,BottomBarMediator);
			mediatorMap.mapView(ClientBarView,ClientBarMediator);  
			trace("Configure: Views Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_VIEWS_COMPLETE));
		}
	}
}