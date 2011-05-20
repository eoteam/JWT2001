package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.main.mediators.BatchUploaderMediator;
	import com.pentagram.main.mediators.ClientsWindowMediator;
	import com.pentagram.main.mediators.CountriesMediator;
	import com.pentagram.main.mediators.ExportSpreadSheetWindowMediator;
	import com.pentagram.main.mediators.HelpWindowMediator;
	import com.pentagram.main.mediators.LoginWindowMediator;
	import com.pentagram.main.mediators.MainMediator;
	import com.pentagram.main.windows.BatchUploader;
	import com.pentagram.main.windows.ClientsWindow;
	import com.pentagram.main.windows.CountriesWindow;
	import com.pentagram.main.windows.ExportSpreadSheetWindow;
	import com.pentagram.main.windows.HelpWindow;
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
			mediatorMap.mapView(ClientsWindow, ClientsWindowMediator);
			mediatorMap.mapView(CountriesWindow, CountriesMediator);
			mediatorMap.mapView(BatchUploader, BatchUploaderMediator);
			mediatorMap.mapView(HelpWindow, HelpWindowMediator);
			trace("Configure: Views Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_VIEWS_COMPLETE));
		}
	}
}