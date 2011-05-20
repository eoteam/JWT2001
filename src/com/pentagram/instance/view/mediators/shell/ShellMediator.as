package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.EditorEvent;
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
	import com.pentagram.events.ViewEvent;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Region;
	import com.pentagram.utils.ModuleUtil;
	import com.pentagram.utils.ViewUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.CollectionEvent;
	import mx.events.IndexChangedEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
	
	public class ShellMediator extends Mediator
	{
		include "ShellMediatorFunctions.as";
		
		[Inject]
		public var view:Shell;
		
		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;  
		
		private var loaders:Array = [];
		private var datasetids:String;
		private var regionOption:Dataset;
		private var fourthSetList:ArrayList;
		private var currentEvent:Event;
		
		override public function onRegister():void
		{
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);		
			
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.LOAD_SEARCH_VIEW,handleLoadSearchView,VisualizerEvent);		
			eventMap.mapListener(eventDispatcher,VisualizerEvent.DATASET_SELECTION_CHANGE,handleDatasetSelection);
			
			eventMap.mapListener(eventDispatcher,VisualizerEvent.TWITTER_SEARCH,handleTwitterSearch);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.TWITTER_RELOAD,handleTwitter);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.TWITTER_SORT,handleTwitter);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.TWITTER_OPTIONS,handleTwitter);
			
			eventMap.mapListener(eventDispatcher,VisualizerEvent.STOP_TIMELINE,handleStopTimeline);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.PLAY_TIMELINE,handlePlayTimeline);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CATEGORY_CHANGE,handleCategoryChange);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.WINDOW_RESIZE,handleFullScreen);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.UPDATE_VISUALIZER_VIEW,handleViewChange);
			
			eventMap.mapListener(eventDispatcher,EditorEvent.ERROR,handleImportFailed);
			eventMap.mapListener(eventDispatcher,EditorEvent.NOTIFY,handleNotification);
			eventMap.mapListener(eventDispatcher,EditorEvent.START_IMPORT,handleStartImport);
			
			eventMap.mapListener(view.stage,FullScreenEvent.FULL_SCREEN,handleFullScreen,FullScreenEvent);
			eventMap.mapListener(view.exportPanel.dirButton,MouseEvent.CLICK,selectedNewDirectory,MouseEvent);
			eventMap.mapListener(view.exportPanel.includeTools,Event.CHANGE,handleIncludeTools,Event);
			eventMap.mapListener(view.exportPanel.saveBtn,MouseEvent.CLICK,handleExportSettingsSave,MouseEvent);
			eventMap.mapListener(view.saveButton,MouseEvent.CLICK,handleInfoChanged,MouseEvent);
			eventMap.mapListener(view.filterTools.comparator,ViewEvent.START_COMPARE,handleCompareBtn,ViewEvent);
	
			eventMap.mapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			
			eventMap.mapListener(view.errorPanel,"okEvent",handleOkError,Event);
			eventMap.mapListener(view.importPanel,"okEvent",handleImport,Event);
			eventMap.mapListener(view.importPanel,"cancelEvent",handleImport,Event);

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
			
			regionOption = new Dataset();
			regionOption.name = "None";
			regionOption.id = -2;
			for each(var r:Region in model.regions) {
				var c:Category = new Category();
				c.name = r.name;
				c.color = r.color;
				c.selected = r.selected;
				regionOption.optionsArray.push(c);
			}
		}
		private function setupFourthSetList(event:CollectionEvent=null):void {
			fourthSetList = new ArrayList();
			fourthSetList.addItem(regionOption);
			for each(var ds:Dataset in model.client.datasets.source) {
				fourthSetList.addItem(ds);
			}
		}
		private function handleStackChange(event:IndexChangedEvent):void {	
			var util:ModuleUtil;
			if(event.newIndex == model.MAP_INDEX && view.mapView.didVisualize){
				restoreDatasets(view.mapView);
				view.mapView.updateSize();
				view.vizTitle.text = view.mapView.datasets[2].name + " by Region";
				datasetids = view.mapView.datasets[2].id.toString();
				checkNotes();
				restoreViewOptions(view.mapView);
				this.formatVizTitle(view.mapView.datasets);
				if(view.mapView.datasets[2].id > 0) 
					view.filterTools.optionsPanel.datasets = new ArrayList([view.mapView.datasets[2]]);
				else
					view.filterTools.optionsPanel.datasets = null;
			}
			else if(event.newIndex == model.GRAPH_INDEX){
			 	if(view.graphView == null) {
					view.bottomTools.firstSet.selectedIndex = view.bottomTools.secondSet.selectedIndex = view.bottomTools.thirdSet.selectedIndex = view.bottomTools.fourthSet.selectedIndex = -1;
					util = new ModuleUtil();
					util.addEventListener("moduleLoaded",handleGraphLoaded);
					util.loadModule("com/pentagram/instance/view/visualizer/GraphView.swf");
					loaders.push(util);
				}
				else if(view.graphView.didVisualize){
					if(view.graphView.datasets[3])
						view.filterTools.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(view.graphView.datasets[3].optionsArray));
					view.graphView.updateSize();
					restoreDatasets(view.graphView);
					view.vizTitle.text = view.graphView.datasets[0].name + " vs " + view.graphView.datasets[1].name + ", sized by " + view.graphView.datasets[2].name;
					datasetids = view.graphView.datasets[0].id.toString()+','+ view.graphView.datasets[1].id.toString()+','+ view.graphView.datasets[2].id.toString();
					
					if(view.graphView.datasets[3]) {
						datasetids += ','+view.graphView.datasets[3].id.toString();
					}
					
					var arr:Array = [];
					if(view.graphView.datasets[0].type == 1)
						arr.push(view.graphView.datasets[0]);
					if(view.graphView.datasets[1].type == 1)
						arr.push(view.graphView.datasets[1]);
					if(view.graphView.datasets[2].type == 1)
						arr.push(view.graphView.datasets[2]);
					view.filterTools.optionsPanel.datasets = new ArrayList(arr);
					
					checkNotes();
					restoreViewOptions(view.graphView);
					this.formatVizTitle(view.graphView.datasets);
				}	
			}
			else if(event.newIndex == model.CLUSTER_INDEX){
				if(view.clusterView == null) {
					util = new ModuleUtil();
					util.addEventListener("moduleLoaded",handleClusterLoaded);
					util.loadModule("com/pentagram/instance/view/visualizer/ClusterView.swf");	
					loaders.push(util);
					view.bottomTools.firstSet.selectedIndex = view.bottomTools.secondSet.selectedIndex = view.bottomTools.thirdSet.selectedIndex = view.bottomTools.fourthSet.selectedIndex = -1;
				}
				else if(view.clusterView.didVisualize)  {
					if(view.clusterView.datasets[2])
						view.filterTools.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(view.clusterView.datasets[2].optionsArray));
					view.clusterView.updateSize();
					restoreDatasets(view.clusterView);
					datasetids = view.clusterView.datasets[2].id.toString()+','+ view.clusterView.datasets[3].id.toString();
					checkNotes();
					restoreViewOptions(view.clusterView);
					this.formatVizTitle(view.clusterView.datasets);
					if(view.clusterView.datasets[3].id > 0) 
						view.filterTools.optionsPanel.datasets = new ArrayList([view.clusterView.datasets[3]]);
					else
						view.filterTools.optionsPanel.datasets = null;
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
					restoreViewOptions(view.twitterView);
				}
			}
		}
		private function handleDatasetSelection(event:VisualizerEvent):void {
			switch(view.visualizerArea.selectedIndex) {
				case model.CLUSTER_INDEX:
					if(event.args[0])
						view.filterTools.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(Dataset(event.args[0]).optionsArray));
					else
						view.filterTools.categoriesPanel.continentList.dataProvider = null;
					
					if(event.args[0].id != -1 && event.args[1].id != -1) {
						view.filterTools.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(event.args[0].optionsArray));	
					}
					else  {
						view.filterTools.categoriesPanel.continentList.dataProvider = model.regions;
					}	
					view.clusterView.visualize(event.args[0],event.args[1],event.args[2]);
					datasetids = event.args[0].id.toString()+','+event.args[1].id.toString();
					checkNotes();
					formatVizTitle(view.clusterView.datasets);
					if(event.args[1].id > 0) 
						view.filterTools.optionsPanel.datasets = new ArrayList([event.args[1]]);
					else
						view.filterTools.optionsPanel.datasets = null;
				break;
				
				case model.MAP_INDEX:
					view.mapView.visualize(event.args[0]);
					view.filterTools.categoriesPanel.continentList.dataProvider = model.regions;
					datasetids = event.args[0].id.toString();
					checkNotes();
					formatVizTitle(view.mapView.datasets);
					if(event.args[0].id > 0) 
						view.filterTools.optionsPanel.datasets = new ArrayList([event.args[0]]);
					else
						view.filterTools.optionsPanel.datasets = null;
				break;
				case model.GRAPH_INDEX:
					
					if(event.args[3].id > -2  && Dataset(event.args[3]).type == 0)
						view.filterTools.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(Dataset(event.args[3]).optionsArray));
					else if(event.args[3].id == -2)
						view.filterTools.categoriesPanel.continentList.dataProvider = null;
					else
						view.filterTools.categoriesPanel.continentList.dataProvider = null;
					
					var y:String;
					if(event.args[4] && event.args[4].length > 0)
						y = event.args[4].getItemAt(0).year;
					
					var d:ArrayCollection = model.normalizeData(view.filterTools.selectedCategories,event.args[0],event.args[1],event.args[2],event.args[3],y);	
					view.graphView.visualize(model.maxRadius,d,event.args[0],event.args[1],event.args[2],event.args[3]);
								
					datasetids = event.args[0].id.toString() + "," + event.args[1].id.toString()  + "," + event.args[2].id.toString();
					
					if(event.args[3]) 
						datasetids += ","+event.args[3].id.toString()
	
					var arr:Array = [];
					if(event.args[0].type == 1)
						arr.push(event.args[0]);
					if(event.args[1].type == 1)
						arr.push(event.args[1]);
					if(event.args[2].type == 1)
						arr.push(event.args[2]);
					view.filterTools.optionsPanel.datasets = new ArrayList(arr);
					
					checkNotes();
					formatVizTitle(view.graphView.datasets);
				break;
				case model.TWITTER_INDEX:
					view.twitterView.changeView(event.args[0]);
					view.filterTools.adjustCategories(event.args[0]);
					view.twitterView.state = event.args[0].value == "none" ?'single':'many';
				break;
			}
		}
		private function handleTwitterSearch(event:VisualizerEvent):void {
			view.twitterView.searchTerm = event.args[0];
			view.vizTitle.text = 'Twitter Visualization for term "' + event.args[0] + '"';
		}
		private function handleTwitter(event:VisualizerEvent):void {
			switch(event.type) {
				case VisualizerEvent.TWITTER_OPTIONS:
					view.twitterView.showOptions(event.args[0]);
				break;
				case VisualizerEvent.TWITTER_RELOAD:
					view.twitterView.reload();
				break;
				case VisualizerEvent.TWITTER_SORT:
					view.twitterView.sort();
				break;
			}
		}
		private function handleTwitterSort(event:VisualizerEvent):void {
			
		}
		private function handleStopTimeline(event:VisualizerEvent):void {
			//view.currentVisualizer.continous = false;
			if(view.currentVisualizer is IDataVisualizer)
				IDataVisualizer(view.currentVisualizer).pause();
		}
		private function restoreDatasets(viz:IDataVisualizer):void {
			view.bottomTools.firstSet.selectedItem 	= viz.datasets[0] ? viz.datasets[0] : null;				
			view.bottomTools.secondSet.selectedItem	= viz.datasets[1] ? viz.datasets[1] : null;				
			view.bottomTools.thirdSet.selectedItem	= viz.datasets[2] ? viz.datasets[2] : null;				
			view.bottomTools.fourthSet.selectedItem	= viz.datasets[3] ? viz.datasets[3] : null;				
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
					view.graphView.updateYear(event.args[0]);
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
						var ds1:Dataset = view.bottomTools.firstSet.selectedItem as Dataset;
						var ds2:Dataset = view.bottomTools.secondSet.selectedItem as Dataset;
						var ds3:Dataset = view.bottomTools.thirdSet.selectedItem as Dataset;
						var ds4:Dataset = view.bottomTools.fourthSet.selectedItem as Dataset;
						var year:String = '';
						if(view.bottomTools.yearSlider.dataProvider && view.bottomTools.yearSlider.dataProvider.length>0) {
							year =  view.bottomTools.yearSlider.dataProvider.getItemAt(view.bottomTools.yearSlider.selectedIndex).year;
						}
						model.updateData(view.filterTools.selectedCategories,view.graphView.visdata,year,ds1,ds2,ds3,ds4);
					}
					viz.updateMaxRadius(value);
				break;
				case "topics" :
					view.twitterView.selectTweets(value as Vector.<Object>);
				break;
				case "countrySelection":
					IDataVisualizer(view.currentVisualizer).selectCountries(event.args[1]);
				break;
				case "rangeSelection":
					ds1 = view.filterTools.optionsPanel.datasetList.selectedItem as Dataset;
					trace(ds1.min,ds1.max);
					ds1.min = event.args[1][0];
					ds1.max = event.args[1][1];
					trace(ds1.min,ds1.max);
					view.currentVisualizer.update();
				break;
				case 'radiusThumbRelease':
					view.currentVisualizer.updateSize();
				break;
			}
		}
		private function handleClientLoaded(event:VisualizerEvent):void
		{
			model.client.datasets.addEventListener(CollectionEvent.COLLECTION_CHANGE,setupFourthSetList);
			setupFourthSetList();
			view.client = model.client;
			var util:ModuleUtil;
			view.visualizerArea.selectedIndex = model.MAP_INDEX;
			
			eventMap.unmapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleStackChange,IndexChangedEvent);
				
			if(view.mapView) {
				
				for each(util in loaders) {
					util.unloadModule();
				}
				view.mapView = null;
				view.clusterView = null;
				view.graphView = null;
				view.twitterView = null;
				loaders = [];
			}
			view.callLater(function resume():void {
				var util:ModuleUtil
				util = new ModuleUtil();
				util.addEventListener("moduleLoaded",handleMapLoaded);
				util.loadModule("com/pentagram/instance/view/visualizer/MapView.swf");
				loaders.push(util);
			});
			model.client.notes.filterFunction = findNoteByDatasets;
		}		
		private function handleGraphLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			util.removeEventListener("moduleLoaded",handleGraphLoaded);
			if(util.view is IGraphView) {
				this.view.graphView = util.view as IGraphView;
				view.graphHolder.addElement(util.view as Group);

				var ds1:Dataset = view.bottomTools.firstSet.selectedItem =  model.client.datasets.length > 1 ?
					model.client.datasets.getItemAt(1) : model.client.datasets.getItemAt(0);
				
				var ds2:Dataset = view.bottomTools.secondSet.selectedItem =  model.client.datasets.length > 2 ?
					model.client.datasets.getItemAt(2) : model.client.datasets.getItemAt(0);
				
				var ds3:Dataset = view.bottomTools.thirdSet.selectedItem =  model.client.quantityDatasets.length > 2 ?
					model.client.quantityDatasets.getItemAt(model.client.quantityDatasets.length-1) : model.client.datasets.getItemAt(0);

				if(ds3 == ds1 || ds3 == ds2) {
					ds3 = model.client.datasets.getItemAt(0) as Dataset;
					view.bottomTools.thirdSet.selectedIndex = 0;
				}
				
				var arr:Array = [];
				if(ds1.type == 1)
					arr.push(ds1);
				if(ds2.type == 1)
					arr.push(ds2);
				if(ds3.type == 1)
					arr.push(ds3);
				view.filterTools.optionsPanel.datasets = new ArrayList(arr);
				
				view.bottomTools.fourthSet.dataProvider = fourthSetList;
				var ds4:Dataset = view.bottomTools.fourthSet.selectedItem = fourthSetList.getItemAt(1);
				this.eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.UPDATE_TIMELINE,[ds1,ds2,ds3,ds4]));
				
				var y:String;
				var years:ArrayList = updateTimeline(ds1,ds2,ds3,ds4);
				if(years && years.length>0)
					y = years.getItemAt(0).year;
				var d:ArrayCollection = model.normalizeData(ds4.options.split(','),ds1,ds2,ds3,ds4,y);		
				view.graphView.visualize(model.maxRadius,d,ds1,ds2,ds3,ds4);
				
				datasetids = ds1.id.toString()+','+ds2.id.toString()+','+ds3.id.toString();
				checkNotes();
				this.formatVizTitle(view.graphView.datasets);
				
				view.filterTools.optionsPanel.maxRadiusSlider.value = 25;
				view.filterTools.optionsPanel.xrayToggle.selected = true;	
			}
		}
		private function handleMapLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IMapView) {
				view.mapHolder.addElement(util.view as Group);
				this.view.mapView = util.view as IMapView;
				util.view.addEventListener('vizComplete',handleVizComplete);
				this.setupMapView();		
			}
		}
		private function setupMapView():void {
			view.filterTools.categoriesPanel.continentList.dataProvider = model.regions;			
			view.mapView.client = model.client;
			view.mapView.categories = model.regions;
			view.mapView.isCompare = model.isCompare;
			
			if(model.client.quantityDatasets.length > 1) {
				var dataset:Dataset = model.selectedSet = model.isCompare ? model.compareArgs[1] : model.client.quantityDatasets.getItemAt(1) as Dataset;
				var year:String;
				if(model.isCompare) {
					year = model.compareArgs[3];
					for each(var r:Region in model.regions.source) {
						if(r.name == model.compareArgs[2].name) {
							r.selected = true;
						}
						else
							r.selected = false;
					}
				}	
				view.mapView.visualize(dataset);
				view.bottomTools.thirdSet.selectedItem = dataset;
				view.filterTools.optionsPanel.datasets = new ArrayList([dataset]);
				this.eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.UPDATE_TIMELINE,[dataset],year));
				datasetids = dataset.id.toString();
				checkNotes();	
			}
			else {
				dataset = model.client.datasets.getItemAt(0) as Dataset;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.TOGGLE_PROGRESS,false));
				view.mapView.visualize(dataset);
				view.bottomTools.thirdSet.selectedItem = dataset;
				view.filterTools.optionsPanel.datasets = null;
			}
			
			this.formatVizTitle(view.mapView.datasets);
			eventMap.mapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleStackChange,IndexChangedEvent);
		}
		private function handleClusterLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			util.removeEventListener("moduleLoaded",handleClusterLoaded);
			if(util.view is IClusterView) {
				this.view.clusterView = util.view as IClusterView;
				view.clusterHolder.addElement(util.view as Group);

				var dataset1:Dataset = model.client.qualityDatasets.length > 1? model.client.qualityDatasets.getItemAt(1) as Dataset:model.client.qualityDatasets.getItemAt(0) as Dataset;
				var dataset2:Dataset = model.client.quantityDatasets.length > 1? model.client.quantityDatasets.getItemAt(1) as Dataset:model.client.quantityDatasets.getItemAt(0) as Dataset
				view.bottomTools.thirdSet.selectedItem = dataset1;
				view.bottomTools.fourthSet.selectedItem = dataset2;
				
				view.clusterView.visualize(dataset1,dataset2,updateTimeline(dataset1,dataset2));
				
				if(dataset1.id != -1) 
					view.filterTools.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(dataset1.optionsArray));					
				else 
					view.filterTools.categoriesPanel.continentList.dataProvider = model.regions;							
				
				if(dataset2.id > 0) 
					view.filterTools.optionsPanel.datasets = new ArrayList([dataset2]);
				else
					view.filterTools.optionsPanel.datasets = null;
				datasetids = dataset1.id.toString()+','+dataset2.id.toString();	
				checkNotes();
				
				this.eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.UPDATE_TIMELINE,[dataset1,dataset2]));
				this.formatVizTitle(view.clusterView.datasets);
				view.filterTools.optionsPanel.maxRadiusSlider.value = 100;
				view.filterTools.optionsPanel.xrayToggle.selected = true;
			}			
		}
		private function handleTwitterLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			util.removeEventListener("moduleLoaded",handleTwitterLoaded);
			if(util.view is ITwitterView) {
				util.view.addEventListener('vizComplete',handleVizComplete);
				util.view.addEventListener('vizStarted',handleVizComplete);
				view.twitterView = util.view as ITwitterView;
				view.twitterView.colors = model.colors;
				view.twitterView.searchTerm = model.client.shortname != '' ?model.client.shortname:model.client.name;
				view.twitterHolder.addElement(util.view as Group);	
				view.filterTools.optionsPanel.maxRadiusSlider.value = 100;
				view.filterTools.optionsPanel.xrayToggle.selected = true;
			}			
		}
		private function handleVizComplete(event:Event):void {
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.TOGGLE_PROGRESS,event.type=='vizComplete'?false:true));
			if(event.target == view.twitterView) {
				if(event.type == 'vizStarted')
					view.bottomTools.twitterOptionsBtn.selected = false;
				else
					view.filterTools.topics.topicsList.dataProvider = new ArrayCollection(view.twitterView.topics);
			}
		}
		private function restoreViewOptions(viz:IVisualizer):void {
			var arr:Array = viz.viewOptions;
			view.filterTools.optionsPanel.maxRadiusSlider.value = arr[0];
			view.filterTools.optionsPanel.xrayToggle.selected = arr[1];
		}
		private function formatVizTitle(datasets:Array):void {
			var t:String = ''
			switch(view.visualizerArea.selectedIndex) {
				case model.MAP_INDEX:
					if(datasets[2].id != -1)
						t = datasets[2].name + " by Region";
					else
						t = "All Countries for " + model.client.name;	
				break;
				
				case model.CLUSTER_INDEX:
					if(datasets[2].id != -1 && datasets[3].id != -1)
						t = datasets[2].name + " by " + datasets[3].name;
					else if(datasets[3].id != -1)
						t = "Color by Region, sized by " + datasets[3].name;
					else
						t= "All Countries for " + model.client.name;
				break;
				
				case model.GRAPH_INDEX:
					if(datasets[0].id != -1)
						t = datasets[0].name; 
					
					if(datasets[1].id != -1) {
						if(datasets[0].id != -1) {	
							t += " vs ";
							t +=  datasets[1].name + ",";
						}
						else {
							t +=  datasets[1].name;
						}
					}
					
					if(datasets[2].id != -1)
						t += " sized by " + datasets[2].name +", ";
					
					if(datasets[3].id > 0)
						t += " grouped by " + datasets[3].name;
					else if(datasets[3].id == -2)
						t += " grouped by region";
					else if(datasets[3].id == -1 && t.charAt(t.length-1) == ',')
						t = t.substr(0,t.length-1);
				break;
				
				case model.TWITTER_INDEX:
				break;
			}
			view.vizTitle.text = t;
		}
		private function updateTimeline(...args):ArrayList {
			var datasets:Array;
			var year:String;
			if(args[0] is ViewEvent)
				datasets = ViewEvent(args[0]).args;
			else datasets = args;
			
			var years:ArrayList = new ArrayList();
			var uniqueYears:Dictionary = new Dictionary();
			var count:int;
			for each(var dataset:Dataset in datasets) {
				if(dataset.time == 1) {	
					count++;
					for (var i:int=0;i<dataset.years.length;i++) {
						year = dataset.years[i];
						if(uniqueYears[year])
							uniqueYears[year] += 1;
						else uniqueYears[year] = 1;
					}
				}
			}
			var ys:Array = [];
			for (year in uniqueYears) {
				if(uniqueYears[year] >= count)
					ys.push(year);
			}
			ys.sort();
			for each(year in ys) {
				years.addItem(new Year(year,year.split('_').join('-'),1)); 	
			}
			return years;
		}
		private function handleCleanup(event:ViewEvent):void {
			this.mediatorMap.removeMediator(this);
		}
		override public function onRemove():void {
			view.mapView.pause();
			for each(var util:ModuleUtil in loaders) {
				util.unloadModule();
			}
			loaders = [];
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);		
			
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.LOAD_SEARCH_VIEW,handleLoadSearchView,VisualizerEvent);		
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.DATASET_SELECTION_CHANGE,handleDatasetSelection);
			
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.TWITTER_SEARCH,handleTwitterSearch);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.TWITTER_RELOAD,handleTwitter);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.TWITTER_SORT,handleTwitter);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.TWITTER_OPTIONS,handleTwitter);
			
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.STOP_TIMELINE,handleStopTimeline);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.PLAY_TIMELINE,handlePlayTimeline);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.CATEGORY_CHANGE,handleCategoryChange);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.WINDOW_RESIZE,handleFullScreen);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.UPDATE_VISUALIZER_VIEW,handleViewChange);
			
			
			eventMap.unmapListener(eventDispatcher,EditorEvent.ERROR,handleImportFailed);
			eventMap.unmapListener(eventDispatcher,EditorEvent.NOTIFY,handleNotification);
			eventMap.unmapListener(eventDispatcher,EditorEvent.START_IMPORT,handleStartImport);
			
			eventMap.unmapListener(view.stage,FullScreenEvent.FULL_SCREEN,handleFullScreen,FullScreenEvent);
			eventMap.unmapListener(view.exportPanel.dirButton,MouseEvent.CLICK,selectedNewDirectory,MouseEvent);
			eventMap.unmapListener(view.exportPanel.includeTools,Event.CHANGE,handleIncludeTools,Event);
			eventMap.unmapListener(view.exportPanel.saveBtn,MouseEvent.CLICK,handleExportSettingsSave,MouseEvent);
			eventMap.unmapListener(view.saveButton,MouseEvent.CLICK,handleInfoChanged,MouseEvent);
			eventMap.unmapListener(view.filterTools.comparator,ViewEvent.START_COMPARE,handleCompareBtn,ViewEvent);
			
			eventMap.unmapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			
			eventMap.unmapListener(view.errorPanel,"okEvent",handleOkError,Event);
			eventMap.unmapListener(view.importPanel,"okEvent",handleImport,Event);
			eventMap.unmapListener(view.importPanel,"cancelEvent",handleImport,Event);			

			eventMap.unmapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleStackChange,IndexChangedEvent);
			
			model.exportDirectory.removeEventListener(Event.SELECT, file_select);
			
			
			model.client.datasets.removeEventListener(CollectionEvent.COLLECTION_CHANGE,setupFourthSetList);
			model.client = null;
			model.selectedSet = null;
			
			trace("Shell Mediator Released");
			super.onRemove();
		}
	}
}
