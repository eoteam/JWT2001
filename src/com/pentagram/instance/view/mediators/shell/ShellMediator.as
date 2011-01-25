package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.model.vo.Year;
	import com.pentagram.instance.view.shell.Shell;
	import com.pentagram.instance.view.visualizer.interfaces.IClusterView;
	import com.pentagram.instance.view.visualizer.interfaces.IGraphView;
	import com.pentagram.instance.view.visualizer.interfaces.IMapView;
	import com.pentagram.instance.view.visualizer.interfaces.IVisualizer;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.User;
	import com.pentagram.utils.ModuleUtil;
	import com.pentagram.utils.ViewUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.IndexChangedEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
	
	public class ShellMediator extends Mediator
	{
		[Inject]
		public var view:Shell;
		
		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;  
		
		
		private var loaders:Array = [];
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.LOAD_SEARCH_VIEW,handleLoadSearchView,VisualizerEvent);		
			eventMap.mapListener(eventDispatcher,VisualizerEvent.DATASET_SELECTION_CHANGE,handleDatasetSelection);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.STOP_TIMELINE,handleStopTimeline);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.PLAY_TIMELINE,handlePlayTimeline);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CATEGORY_CHANGE,handleCategoryChange);

			
			eventMap.mapListener(eventDispatcher,VisualizerEvent.UPDATE_VISUALIZER_VIEW,handleViewChange);
			
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent,false,0,true);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent,false,0,true);
			
			eventMap.mapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleStackChange,IndexChangedEvent,false,0,true);
			eventMap.mapListener(view.stage,FullScreenEvent.FULL_SCREEN,handleFullScreen,FullScreenEvent,false,0,true);
		
			eventMap.mapListener(eventDispatcher,VisualizerEvent.WINDOW_RESIZE,handleFullScreen);
			eventMap.mapListener(view.exportPanel.dirButton,MouseEvent.CLICK,selectedNewDirectory);
			eventMap.mapListener(view.exportPanel.includeTools,Event.CHANGE,handleIncludeTools);
			eventMap.mapListener(view.exportPanel.saveBtn,MouseEvent.CLICK,handleExportSettingsSave);
				
			if(model.user) {
				view.currentState = view.loggedInState.name;
				model.exportMenuItem.enabled = true;
				model.importMenuItem.enabled = true;
			}
			else {
				model.exportMenuItem.enabled = false;
				model.importMenuItem.enabled = false;
				view.currentState = view.loggedOutState.name;
			}
			
			model.exportDirectory = File.desktopDirectory;
			view.exportPanel.dirPath.text = model.exportDirectory.nativePath;
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.SHELL_LOADED));
		}
		private function handleIncludeTools(event:Event):void {
			model.includeTools = view.exportPanel.includeTools.selected;
		}
		private function selectedNewDirectory(event:MouseEvent):void {
			model.exportDirectory = new File();
			model.exportDirectory.addEventListener(Event.SELECT, file_select);
			model.exportDirectory.browseForDirectory("Please select a directory...")
		}
		private function file_select(evt:Event):void {
			view.exportPanel.dirPath.text = model.exportDirectory.nativePath;
		}
		private function handleStackChange(event:IndexChangedEvent):void {
			var util:ModuleUtil;
			if(event.newIndex == model.MAP_INDEX){
				restoreDatasets(view.mapView);
				view.mapView.updateSize();
				
			}
			else if(event.newIndex == model.GRAPH_INDEX){
			 	if(view.graphView == null) {
					view.tools.firstSet.selectedIndex = view.tools.secondSet.selectedIndex = view.tools.thirdSet.selectedIndex = view.tools.fourthSet.selectedIndex = -1;
					util = new ModuleUtil();
					util.addEventListener("moduleLoaded",handleGraphLoaded);
					util.loadModule("com/pentagram/instance/view/visualizer/GraphView.swf");
					loaders.push(util);
				}
				else {
					if(view.graphView.datasets[3])
						view.filterTools.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(view.graphView.datasets[3].optionsArray));
					view.graphView.updateSize();
					restoreDatasets(view.graphView);
				}	
			}
			else if(event.newIndex == model.CLUSTER_INDEX){
				if(view.clusterView == null) {
					util = new ModuleUtil();
					util.addEventListener("moduleLoaded",handleClusterLoaded);
					util.loadModule("com/pentagram/instance/view/visualizer/ClusterView.swf");	
					loaders.push(util);
					view.tools.firstSet.selectedIndex = view.tools.secondSet.selectedIndex = view.tools.thirdSet.selectedIndex = view.tools.fourthSet.selectedIndex = -1;
				}
				else  {
					if(view.clusterView.datasets[2])
						view.filterTools.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(view.clusterView.datasets[2].optionsArray));
					view.clusterView.updateSize();
					restoreDatasets(view.clusterView);
				}
			}
		}
		private function handleDatasetSelection(event:VisualizerEvent):void {
			switch(view.visualizerArea.selectedIndex) {
				case model.CLUSTER_INDEX:
					if(event.args[0])
						view.filterTools.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(Dataset(event.args[0]).optionsArray));
					else
						view.filterTools.continentList.dataProvider = null;
					view.clusterView.visualize(event.args[0],event.args[1]);
				break;
				case model.MAP_INDEX:
					view.mapView.visualize(event.args[0]);
					view.filterTools.continentList.dataProvider = model.regions;
				break;
				case model.GRAPH_INDEX:
					
					if(event.args[3] && Dataset(event.args[3]).type == 0)
						view.filterTools.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(Dataset(event.args[3]).optionsArray));
					else
						view.filterTools.continentList.dataProvider = model.regions;
					
					var d:ArrayCollection = model.normalizeData(view.filterTools.selectedCategories,event.args[0],event.args[1],event.args[2],event.args[3]);	
					view.graphView.visualize(model.maxRadius,d,event.args[0],event.args[1],event.args[2],event.args[3]);
				break;
			}
		}
		private function handleStopTimeline(event:VisualizerEvent):void {
			view.currentVisualizer.continous = false;
			view.currentVisualizer.pause();
		}
		private function restoreDatasets(viz:IVisualizer):void {
			view.tools.firstSet.selectedItem 	= viz.datasets[0] ? viz.datasets[0] : null;				
			view.tools.secondSet.selectedItem	= viz.datasets[1] ? viz.datasets[1] : null;				
			view.tools.thirdSet.selectedItem	= viz.datasets[2] ? viz.datasets[2] : null;				
			view.tools.fourthSet.selectedItem	= viz.datasets[3] ? viz.datasets[3] : null;				
		}
		private function handlePlayTimeline(event:VisualizerEvent):void {
			view.currentVisualizer.continous = true;
			switch(view.visualizerArea.selectedIndex) {
				case model.CLUSTER_INDEX:
					view.clusterView.updateYear(event.args[0]);
				break;
				case model.MAP_INDEX:
					view.mapView.updateYear(event.args[0]);
					break;
				case model.GRAPH_INDEX:	
					model.updateData(view.filterTools.selectedCategories,
									 view.graphView.visdata,event.args[0],event.args[1],event.args[2],event.args[3],event.args[4]);
					view.graphView.update();
					break;
			}
		}
		private function handleCategoryChange(event:VisualizerEvent):void {
			var type:String = event.args[0];
			var item:Category = event.args[1] as Category;	
			switch(type) {
				case "addRegion":
					view.currentVisualizer.addCategory(item);
					break;
				
				case "selectRegion":
					view.currentVisualizer.selectCategory(item);
				break;
				
				case "removeRegion":
					view.currentVisualizer.removeCategory(item);
				break;
				case "selectAll":
					view.currentVisualizer.selectAllCategories();
				break;
			}
		}
	
		private function handleViewChange(event:VisualizerEvent):void {
			var prop:String = event.args[0];
			var value:* = event.args[1];
			switch(prop) {
				case 'alpha':
					view.currentVisualizer.toggleOpacity(value);
				break;
				case 'mapToggle':
					if(view.visualizerArea.selectedIndex == model.MAP_INDEX)
						view.mapView.toggleMap(value);
				break;
				case 'maxRadius':
					if(view.visualizerArea.selectedIndex == model.GRAPH_INDEX) {
					var ds1:Dataset = view.tools.firstSet.selectedItem as Dataset;
					var ds2:Dataset = view.tools.secondSet.selectedItem as Dataset;
					var ds3:Dataset = view.tools.thirdSet.selectedItem as Dataset;
					var ds4:Dataset = view.tools.fourthSet.selectedItem as Dataset;
					var year:int =  view.tools.yearSlider.dataProvider.getItemAt(view.tools.yearSlider.selectedIndex).year as int;
					model.updateData(view.filterTools.selectedCategories,view.graphView.visdata,year,ds1,ds2,ds3,ds4);
					}
					view.currentVisualizer.updateMaxRadius(value);
				break;
			}
		}
		
		private function handleClientLoaded(event:VisualizerEvent):void
		{
			view.client = model.client;
			var util:ModuleUtil = new ModuleUtil();
			util.addEventListener("moduleLoaded",handleMapLoaded);
			util.loadModule("com/pentagram/instance/view/visualizer/MapView.swf");
			loaders.push(util);
		}
		private function handleLoadSearchView(event:VisualizerEvent):void
		{
			view.client = null;
			view.clientBar.infoBtn.selected = false;
			view.clientBar.currentState = view.clientBar.closedState.name;
		}
		private function handleLogin(event:AppEvent):void
		{
			model.user = event.args[0] as User;
			model.exportMenuItem.enabled = true;
			model.importMenuItem.enabled = true;
			view.currentState = view.loggedInState.name;
		}
		private function handleLogout(event:AppEvent):void
		{
			model.user = null;
			view.currentState = view.loggedOutState.name;
		}	
		private function handleGraphLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IGraphView) {
				this.view.graphView = util.view as IGraphView;
				view.graphHolder.addElement(util.view as Group);
				var ds1:Dataset = view.tools.firstSet.selectedItem =  view.tools.firstSet.dataProvider.getItemAt(0) as Dataset;
				var ds2:Dataset = view.tools.secondSet.selectedItem =  view.tools.secondSet.dataProvider.getItemAt(0) as Dataset;
				var ds3:Dataset = view.tools.thirdSet.selectedItem =  view.tools.thirdSet.dataProvider.getItemAt(0) as Dataset;
				var ds4:Dataset = view.tools.firstSet.dataProvider.getItemAt(0) as Dataset;
				var d:ArrayCollection = model.normalizeData(view.filterTools.selectedCategories,ds1,ds2,ds3,null);		
				view.graphView.visualize(model.maxRadius,d,ds1,ds2,ds3,null);
			}
		}
		private function handleMapLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IMapView) {
				view.filterTools.continentList.dataProvider = model.regions;
				this.view.mapView = util.view as IMapView;
				IMapView(util.view).client = model.client;
				view.mapHolder.addElement(util.view as Group);
				var dataset:Dataset = model.client.quantityDatasets.getItemAt(0) as Dataset;
				view.mapView.visualize(dataset);
				view.tools.thirdSet.selectedItem = dataset;
				
				var years:ArrayList = new ArrayList();
				if(dataset.time == 1) {
					view.tools.timelineContainer.visible = true;
					
					for (var i:int=dataset.years[0];i<=dataset.years[1];i++) {
						years.addItem(new Year(i,1)); 
					}
					view.tools.yearSlider.dataProvider = years;
				}
			}
		}
		private function handleClusterLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IClusterView) {
				this.view.clusterView = util.view as IClusterView;
				view.clusterHolder.addElement(util.view as Group);
				
				var dataset1:Dataset = model.client.qualityDatasets.getItemAt(0) as Dataset;
				var dataset2:Dataset = model.client.quantityDatasets.getItemAt(0) as Dataset;
				view.tools.thirdSet.selectedItem = dataset1;
				view.tools.fourthSet.selectedItem = dataset2;
				view.clusterView.visualize(dataset1,dataset2);
				view.filterTools.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(dataset1.optionsArray));
			}			
		}
		private function handleFullScreen(event:Event):void{
			view.currentVisualizer.updateSize();
		}
		private function handleExportSettingsSave(event:MouseEvent):void {
			view.exportPanel.visible = false;
		}
	}
}