package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.model.vo.Year;
	import com.pentagram.instance.view.shell.Shell;
	import com.pentagram.instance.view.visualizer.interfaces.IClusterView;
	import com.pentagram.instance.view.visualizer.interfaces.IDataVisualizer;
	import com.pentagram.instance.view.visualizer.interfaces.IGraphView;
	import com.pentagram.instance.view.visualizer.interfaces.IMapView;
	import com.pentagram.instance.view.visualizer.interfaces.ITwitterView;
	import com.pentagram.instance.view.visualizer.interfaces.IVisualizer;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Note;
	import com.pentagram.model.vo.Region;
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
	import spark.events.TextOperationEvent;
	
	public class ShellMediator extends Mediator
	{
		[Inject]
		public var view:Shell;
		
		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;  
		
		
		private var loaders:Array = [];
		private var datasetids:String;
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.LOAD_SEARCH_VIEW,handleLoadSearchView,VisualizerEvent);		
			eventMap.mapListener(eventDispatcher,VisualizerEvent.DATASET_SELECTION_CHANGE,handleDatasetSelection);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.STOP_TIMELINE,handleStopTimeline);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.PLAY_TIMELINE,handlePlayTimeline);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CATEGORY_CHANGE,handleCategoryChange);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.WINDOW_RESIZE,handleFullScreen);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.UPDATE_VISUALIZER_VIEW,handleViewChange);
			
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			
			eventMap.mapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleStackChange,IndexChangedEvent);
			eventMap.mapListener(view.stage,FullScreenEvent.FULL_SCREEN,handleFullScreen,FullScreenEvent);
			eventMap.mapListener(view.exportPanel.dirButton,MouseEvent.CLICK,selectedNewDirectory,MouseEvent);
			eventMap.mapListener(view.exportPanel.includeTools,Event.CHANGE,handleIncludeTools,Event);
			eventMap.mapListener(view.exportPanel.saveBtn,MouseEvent.CLICK,handleExportSettingsSave,MouseEvent);
			eventMap.mapListener(view.saveButton,MouseEvent.CLICK,handleInfoChanged,MouseEvent);
			
				
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
				view.vizTitle.text = view.mapView.datasets[2].name + " by Region";
				datasetids = view.mapView.datasets[2].id.toString();
				checkNotes();
				restoreViewOptions(view.mapView);
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
					view.vizTitle.text = view.graphView.datasets[0].name + " vs " + view.graphView.datasets[1].name + ", sized by " + view.graphView.datasets[2].name;
					datasetids = view.graphView.datasets[0].id.toString()+','+ view.graphView.datasets[1].id.toString()+','+ view.graphView.datasets[2].id.toString();
					if(view.graphView.datasets[3]) {
						view.vizTitle.text += ", grouped by " + view.graphView.datasets[3].name;
						datasetids += ','+view.graphView.datasets[3].id.toString();
					}
					else
						view.vizTitle.text += ", grouped by region";	
					checkNotes();
					restoreViewOptions(view.graphView);
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
					view.vizTitle.text = view.clusterView.datasets[2].name + " by " + view.clusterView.datasets[3].name;
					datasetids = view.clusterView.datasets[2].id.toString()+','+ view.clusterView.datasets[3].id.toString();
					checkNotes();
					restoreViewOptions(view.clusterView);
				}
			}
			else if(event.newIndex == model.TWITTER_INDEX){ 
				view.vizTitle.text = 'Twitter Visualization for term "' + model.client.shortname+'"';
				view.infoText.text = '';
				if(view.twitterView == null) {
					util = new ModuleUtil();
					util.addEventListener("moduleLoaded",handleTwitterLoaded);
					util.loadModule("com/pentagram/instance/view/visualizer/TwitterView.swf");	
					loaders.push(util);
				}
				else {
					view.twitterView.client = model.client;
					restoreViewOptions(view.twitterView);
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
					view.vizTitle.text = event.args[0].name + " by " + event.args[1].name;
					datasetids = event.args[0].id.toString()+','+event.args[1].id.toString();
					checkNotes();
				break;
				case model.MAP_INDEX:
					view.mapView.visualize(event.args[0]);
					view.filterTools.continentList.dataProvider = model.regions;
					view.vizTitle.text = event.args[0].name + " by Region";
					datasetids = event.args[0].id.toString();
					checkNotes();
				break;
				case model.GRAPH_INDEX:
					
					if(event.args[3] && Dataset(event.args[3]).type == 0)
						view.filterTools.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(Dataset(event.args[3]).optionsArray));
					else
						view.filterTools.continentList.dataProvider = model.regions;
					
					var d:ArrayCollection = model.normalizeData(view.filterTools.selectedCategories,event.args[0],event.args[1],event.args[2],event.args[3]);	
					view.graphView.visualize(model.maxRadius,d,event.args[0],event.args[1],event.args[2],event.args[3]);
					view.vizTitle.text = event.args[0].name + " vs " + event.args[1].name + ", sized by " + event.args[2].name;
					datasetids = event.args[0].id.toString() + "," + event.args[1].id.toString()  + "," + event.args[2].id.toString();
					if(event.args[3]) {
						view.vizTitle.text += ", grouped by " + event.args[3].name;
						datasetids += ","+event.args[3].id.toString()
					}
					else
						view.vizTitle.text += ", grouped by region";
					
					checkNotes();
				break;
			}
		}
		private function handleStopTimeline(event:VisualizerEvent):void {
			//view.currentVisualizer.continous = false;
			if(view.currentVisualizer is IDataVisualizer)
				IDataVisualizer(view.currentVisualizer).pause();
		}
		private function restoreDatasets(viz:IDataVisualizer):void {
			view.tools.firstSet.selectedItem 	= viz.datasets[0] ? viz.datasets[0] : null;				
			view.tools.secondSet.selectedItem	= viz.datasets[1] ? viz.datasets[1] : null;				
			view.tools.thirdSet.selectedItem	= viz.datasets[2] ? viz.datasets[2] : null;				
			view.tools.fourthSet.selectedItem	= viz.datasets[3] ? viz.datasets[3] : null;				
		}
		private function handlePlayTimeline(event:VisualizerEvent):void {
			//view.currentVisualizer.continous = true;
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
			var count:int = event.args[2] as int;
			if(view.currentVisualizer is IDataVisualizer) {
				var viz:IDataVisualizer = view.currentVisualizer as IDataVisualizer
				switch(type) {
					case "addRegion":
						viz.addCategory(item,count);
						break;
					
					case "selectRegion":
						viz.selectCategory(item);
					break;
					
					case "removeRegion":
						viz.removeCategory(item,count);
					break;
					case "selectAll":
						viz.selectAllCategories();
					break;
				}
			}
		}
	
		private function handleViewChange(event:VisualizerEvent):void {
			var prop:String = event.args[0];
			var value:* = event.args[1];
			
			var viz:IVisualizer = view.currentVisualizer
			switch(prop) {
				case 'alpha':
					viz.toggleOpacity(value);
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
					viz.updateMaxRadius(value);
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
			model.client.notes.filterFunction = findNoteByDatasets;
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
				view.vizTitle.text = ds1.name + " vs " + ds2.name + ", sized by " + ds3.name;
				view.vizTitle.text += ", grouped by region";
				datasetids = ds1.id.toString()+','+ds2.id.toString()+','+ds3.id.toString();
				checkNotes();
				view.filterTools.optionsPanel.maxRadiusSlider.value = 75/2;
				view.filterTools.optionsPanel.xrayToggle.selected = true;
			}
		}
		private function handleMapLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IMapView) {
				view.filterTools.continentList.dataProvider = model.regions;
				this.view.mapView = util.view as IMapView;
				IMapView(util.view).client = model.client;
				IMapView(util.view).categories = model.regions;
				IMapView(util.view).isCompare = model.isCompare;
				view.mapHolder.addElement(util.view as Group);
				var dataset:Dataset = model.selectedSet = model.isCompare ? model.compareArgs[1] : model.client.quantityDatasets.getItemAt(0) as Dataset;
				view.vizTitle.text = dataset.name + " by Region";
				if(model.isCompare) {
					for each(var r:Region in model.regions.source) {
						if(r.name == model.compareArgs[2].name) {
							r.selected = true;
						}
						else
							r.selected = false;
					}
				}				
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
				datasetids = dataset.id.toString();
				checkNotes();
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
				
				view.filterTools.optionsPanel.maxRadiusSlider.value = 75/2;
				view.filterTools.optionsPanel.xrayToggle.selected = true;
				
				view.vizTitle.text = dataset1.name + " by " + dataset2.name;
				datasetids = dataset1.id.toString()+','+dataset2.id.toString();
				checkNotes();
				
			}			
		}
		private function handleTwitterLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is ITwitterView) {
				view.twitterView = util.view as ITwitterView;
				view.twitterView.client = model.client;
				view.twitterHolder.addElement(util.view as Group);	
			}			
		}
		private function handleFullScreen(event:Event):void{
			view.currentVisualizer.updateSize();
		}
		private function handleExportSettingsSave(event:MouseEvent):void {
			view.exportPanel.visible = false;
		}
		private function findNoteByDatasets(note:Note):Boolean {
			return note.datasets == datasetids;
		}
		private function handleInfoChanged(event:MouseEvent):void {
			var note:Note
			if(model.client.notes.length == 1) {
				note = model.client.notes.getItemAt(0) as Note;
				note.description = view.infoText.text;
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_NOTE,note));
			}
			else {
				note = new Note();
				note.description = view.infoText.text;
				note.clientid = model.client.id;
				note.datasets = datasetids;
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_NOTE,note));
			}
		}
		private function checkNotes():void {
			model.client.notes.refresh();
			if(model.client.notes.length  == 1) {
				view.infoText.text = Note(model.client.notes.getItemAt(0)).description;	
			}
			else
				view.infoText.text = '';		
		}
		private function restoreViewOptions(viz:IVisualizer):void {
			var arr:Array = viz.viewOptions;
			view.filterTools.optionsPanel.maxRadiusSlider.value = arr[0];
			view.filterTools.optionsPanel.xrayToggle.selected = arr[1];
			//view.tools.yearSlider.selectedItem
		}
	}
}