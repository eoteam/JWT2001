package com.pentagram.instance
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.controller.CreateDatasetCommand;
	import com.pentagram.instance.controller.DeleteDatasetCommand;
	import com.pentagram.instance.controller.LoadClientCommand;
	import com.pentagram.instance.controller.UpdateClientCommand;
	import com.pentagram.instance.model.InstanceModel;
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
	import com.pentagram.services.DatasetService;
	import com.pentagram.services.InstanceService;
	import com.pentagram.services.interfaces.IDatasetService;
	import com.pentagram.services.interfaces.IInstanceService;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	
	import mx.core.FlexGlobals;
	
	import org.robotlegs.mvcs.Context;
		
	public class InstanceContext extends Context
	{
		public function InstanceContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true)
		{
			super(contextView, autoStartup);
		}
		
		override public function startup():void
		{  
			
			injector.mapValue(EventDispatcher, FlexGlobals.topLevelApplication.applicationEventDispatcher, "ApplicationEventDispatcher"); 
			
			commandMap.mapEvent(VisualizerEvent.CLIENT_SELECTED,LoadClientCommand,VisualizerEvent);
			commandMap.mapEvent(EditorEvent.UPDATE_CLIENT_DATA,UpdateClientCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.CREATE_DATASET,CreateDatasetCommand,EditorEvent);
			commandMap.mapEvent(EditorEvent.DELETE_DATASET,DeleteDatasetCommand,EditorEvent);  
			
			
			injector.mapSingletonOf(IDatasetService, DatasetService); 
			injector.mapSingletonOf(IInstanceService, InstanceService);
			
			injector.mapSingleton(InstanceModel);
			
			mediatorMap.mapView(InstanceWindow, ViewInstanceMediator);
			//instance views
			mediatorMap.mapView(SearchView,	SearchViewMediator);
			mediatorMap.mapView(BottomBarView,BottomBarMediator);
			mediatorMap.mapView(ShellView,ShellMediator);
			
			mediatorMap.mapView(EditorMainView,EditorMediator); 
			mediatorMap.mapView(OverviewEditor,OverviewEditorMediator);
			mediatorMap.mapView(DatasetCreator,DatasetCreatorMediator); 
			mediatorMap.mapView(DatasetEditor,DatasetEditorMediator); 

		}
		override public function shutdown():void {
			injector.unmap(EventDispatcher,"ApplicationEventDispatcher");
			mediatorMap.enabled = false;
			commandMap.unmapEvents();
			super.shutdown();
		}
	}
}