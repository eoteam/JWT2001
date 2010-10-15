package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.view.MainView;
	import com.pentagram.view.components.BottomBarView;
	import com.pentagram.view.components.ClientBarView;
	import com.pentagram.view.components.EditorMainView;
	import com.pentagram.view.components.OverviewEditor;
	import com.pentagram.view.components.SearchView;
	import com.pentagram.view.components.ShellView;
	import com.pentagram.view.mediators.BottomBarMediator;
	import com.pentagram.view.mediators.EditorMediator;
	import com.pentagram.view.mediators.MainViewMediator;
	import com.pentagram.view.mediators.SearchViewMediator;
	import com.pentagram.view.mediators.ShellMediator;
	
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
			mediatorMap.mapView(ShellView,ShellMediator);  
			mediatorMap.mapView(EditorMainView,EditorMediator); 
			trace("Configure: Views Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_VIEWS_COMPLETE));
		}
	}
}