package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.main.mediators.ClientWindowMediator;
	import com.pentagram.main.mediators.CountriesMediator;
	import com.pentagram.main.mediators.ExportSpreadSheetWindowMediator;
	import com.pentagram.main.mediators.LoginWindowMediator;
	import com.pentagram.main.mediators.MainMediator;
	import com.pentagram.main.windows.ClientListWindow;
	import com.pentagram.main.windows.CountriesWindow;
	import com.pentagram.main.windows.ExportSpreadSheetWindow;
	import com.pentagram.main.windows.LoginWindow;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureViewsCommand extends Command
	{
		override public function execute():void
		{
			//views and singleton windows
			mediatorMap.mapView(View, MainMediator);			
			mediatorMap.mapView(LoginWindow, LoginWindowMediator);
			mediatorMap.mapView(ExportSpreadSheetWindow, ExportSpreadSheetWindowMediator); 
			mediatorMap.mapView(ClientListWindow, ClientWindowMediator);
			mediatorMap.mapView(CountriesWindow, CountriesMediator);
			trace("Configure: Views Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_VIEWS_COMPLETE));
		}
	}
}