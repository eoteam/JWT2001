package com.pentagram.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.instance.view.editor.DatasetCreator;
	import com.pentagram.instance.view.editor.DatasetEditor;
	import com.pentagram.instance.view.editor.EditorMainView;
	import com.pentagram.instance.view.editor.OverviewEditor;
	import com.pentagram.instance.view.mediators.ViewInstanceMediator;
	import com.pentagram.instance.view.mediators.editor.DatasetCreatorMediator;
	import com.pentagram.instance.view.mediators.editor.DatasetEditorMediator;
	import com.pentagram.instance.view.mediators.editor.EditorMediator;
	import com.pentagram.instance.view.mediators.editor.OverviewEditorMediator;
	import com.pentagram.instance.view.mediators.shell.BottomBarMediator;
	import com.pentagram.instance.view.mediators.shell.SearchViewMediator;
	import com.pentagram.instance.view.mediators.shell.ShellMediator;
	import com.pentagram.instance.view.shell.BottomBarView;
	import com.pentagram.instance.view.shell.SearchView;
	import com.pentagram.instance.view.shell.ShellView;
	import com.pentagram.main.mediators.ExportSpreadSheetWindowMediator;
	import com.pentagram.main.mediators.LoginWindowMediator;
	import com.pentagram.main.mediators.MainMediator;
	import com.pentagram.main.windows.ExportSpreadSheetWindow;
	import com.pentagram.main.windows.LoginWindow;
	import com.pentagram.instance.InstanceWindow;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureViewsCommand extends Command
	{
		override public function execute():void
		{
			//views and singleton windows
			mediatorMap.mapView(Main, MainMediator);			
			mediatorMap.mapView(LoginWindow, LoginWindowMediator);
			mediatorMap.mapView(ExportSpreadSheetWindow, ExportSpreadSheetWindowMediator); 
			
			trace("Configure: Views Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_VIEWS_COMPLETE));
		}
	}
}