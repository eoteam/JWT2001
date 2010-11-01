package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.view.components.BottomBarView;
	import com.pentagram.view.components.ClientBarView;
	import com.pentagram.view.components.SearchView;
	import com.pentagram.view.components.ShellView;
	import com.pentagram.view.components.editor.DatasetCreator;
	import com.pentagram.view.components.editor.DatasetEditor;
	import com.pentagram.view.components.editor.EditorMainView;
	import com.pentagram.view.components.editor.OverviewEditor;
	import com.pentagram.view.components.windows.ExportSpreadSheetWindow;
	import com.pentagram.view.components.windows.LoginWindow;
	import com.pentagram.view.components.MainWindow;
	import com.pentagram.view.mediators.BottomBarMediator;
	import com.pentagram.view.mediators.MainMediator;
	import com.pentagram.view.mediators.MainWindowMediator;
	import com.pentagram.view.mediators.SearchViewMediator;
	import com.pentagram.view.mediators.ShellMediator;
	import com.pentagram.view.mediators.editor.DatasetCreatorMediator;
	import com.pentagram.view.mediators.editor.DatasetEditorMediator;
	import com.pentagram.view.mediators.editor.EditorMediator;
	import com.pentagram.view.mediators.editor.OverviewEditorMediator;
	import com.pentagram.view.mediators.windows.ExportSpreadSheetWindowMediator;
	import com.pentagram.view.mediators.windows.LoginWindowMediator;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;
	
	public class ConfigureViewsCommand extends Command
	{
		override public function execute():void
		{
			//views
			
			mediatorMap.mapView(Main, MainMediator);
			mediatorMap.mapView(SearchView,	SearchViewMediator);
			mediatorMap.mapView(MainWindow, MainWindowMediator);
			mediatorMap.mapView(BottomBarView,BottomBarMediator);
			mediatorMap.mapView(ShellView,ShellMediator);
			
			mediatorMap.mapView(EditorMainView,EditorMediator); 
			mediatorMap.mapView(OverviewEditor,OverviewEditorMediator);
			mediatorMap.mapView(DatasetCreator,DatasetCreatorMediator);
			mediatorMap.mapView(DatasetEditor,DatasetEditorMediator); 
			
			mediatorMap.mapView(LoginWindow, LoginWindowMediator); 
			mediatorMap.mapView(ExportSpreadSheetWindow, ExportSpreadSheetWindowMediator);  
			trace("Configure: Views Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_VIEWS_COMPLETE));
		}
	}
}