package com.pentagram.instance.controller.configuration
{
	import com.pentagram.AppConfigStateConstants;
	import com.pentagram.instance.InstanceWindow;
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
	import com.pentagram.instance.view.mediators.shell.BottomToolsMediator;
	import com.pentagram.instance.view.mediators.shell.LoginPanelMediator;
	import com.pentagram.instance.view.mediators.shell.RightToolsMediator;
	import com.pentagram.instance.view.mediators.shell.SearchViewMediator;
	import com.pentagram.instance.view.mediators.shell.ShellMediator;
	import com.pentagram.instance.view.shell.BottomBar;
	import com.pentagram.instance.view.shell.BottomTools;
	import com.pentagram.instance.view.shell.LoginPanel;
	import com.pentagram.instance.view.shell.RightTools;
	import com.pentagram.instance.view.shell.Search;
	import com.pentagram.instance.view.shell.Shell;
	import com.pentagram.main.mediators.ExportSpreadSheetWindowMediator;
	import com.pentagram.main.mediators.LoginWindowMediator;
	import com.pentagram.main.mediators.MainMediator;
	import com.pentagram.main.windows.ExportSpreadSheetWindow;
	import com.pentagram.main.windows.LoginWindow;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.statemachine.StateEvent;

	public class ConfigureViewsCommand extends Command
	{
		override public function execute():void
		{
			mediatorMap.mapView(InstanceWindow, ViewInstanceMediator);

			mediatorMap.mapView(Search,	SearchViewMediator);
			mediatorMap.mapView(BottomBar,BottomBarMediator);
			mediatorMap.mapView(Shell,ShellMediator);
			mediatorMap.mapView(RightTools, RightToolsMediator);
			mediatorMap.mapView(BottomTools, BottomToolsMediator);
			mediatorMap.mapView(LoginPanel, LoginPanelMediator);
			
			
			mediatorMap.mapView(EditorMainView,EditorMediator); 
			mediatorMap.mapView(OverviewEditor,OverviewEditorMediator);
			mediatorMap.mapView(DatasetCreator,DatasetCreatorMediator); 
			mediatorMap.mapView(DatasetEditor,DatasetEditorMediator); 		
						
			trace("Configure Instance: Views Complete");
			eventDispatcher.dispatchEvent( new StateEvent(StateEvent.ACTION, AppConfigStateConstants.CONFIGURE_VIEWS_COMPLETE));
		}
	}
}