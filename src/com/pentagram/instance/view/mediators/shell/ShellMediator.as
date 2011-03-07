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
	import com.pentagram.main.event.ViewEvent;
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

			
			view.errorPanel.addEventListener("okEvent",handleOkError,false,0,true);
			view.importPanel.addEventListener("okEvent",handleImport,false,0,true);
			view.importPanel.addEventListener("cancelEvent",handleImport,false,0,true);
			
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
			regionOption.name = "Region";
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
					view.filterTools.numericFilter.dataset = view.mapView.datasets[2];
				else
					view.filterTools.numericFilter.dataset = null;
			}
			else if(event.newIndex == model.GRAPH_INDEX){
			 	if(view.graphView == null) {
					view.tools.firstSet.selectedIndex = view.tools.secondSet.selectedIndex = view.tools.thirdSet.selectedIndex = view.tools.fourthSet.selectedIndex = -1;
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
					view.tools.firstSet.selectedIndex = view.tools.secondSet.selectedIndex = view.tools.thirdSet.selectedIndex = view.tools.fourthSet.selectedIndex = -1;
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
						view.filterTools.numericFilter.dataset = view.clusterView.datasets[3];
					else
						view.filterTools.numericFilter.dataset = null;
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
					//client selected
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
					view.clusterView.visualize(event.args[0],event.args[1]);
					datasetids = event.args[0].id.toString()+','+event.args[1].id.toString();
					checkNotes();
					formatVizTitle(view.clusterView.datasets);
					if(event.args[1].id > 0) 
						view.filterTools.numericFilter.dataset = event.args[1];
					else
						view.filterTools.numericFilter.dataset = null;
				break;
				
				case model.MAP_INDEX:
					view.mapView.visualize(event.args[0]);
					view.filterTools.categoriesPanel.continentList.dataProvider = model.regions;
					datasetids = event.args[0].id.toString();
					checkNotes();
					formatVizTitle(view.mapView.datasets);
					if(event.args[0].id > 0) 
						view.filterTools.numericFilter.dataset = event.args[0];
					else
						view.filterTools.numericFilter.dataset = null;
				break;
				case model.GRAPH_INDEX:
					
					if(event.args[3].id > 0  && Dataset(event.args[3]).type == 0)
						view.filterTools.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(Dataset(event.args[3]).optionsArray));
					else if(event.args[3].id == -2)
						view.filterTools.categoriesPanel.continentList.dataProvider = model.regions;
					else
						view.filterTools.categoriesPanel.continentList.dataProvider = null;
					
					var d:ArrayCollection = model.normalizeData(view.filterTools.selectedCategories,event.args[0],event.args[1],event.args[2],event.args[3]);	
					view.graphView.visualize(model.maxRadius,d,event.args[0],event.args[1],event.args[2],event.args[3]);
								
					datasetids = event.args[0].id.toString() + "," + event.args[1].id.toString()  + "," + event.args[2].id.toString();
					
					if(event.args[3]) 
						datasetids += ","+event.args[3].id.toString()
	
					checkNotes();
					formatVizTitle(view.graphView.datasets);
				break;
				case model.TWITTER_INDEX:
					view.twitterView.changeView(event.args[0]);
					view.filterTools.adjustCategories(event.args[0]);
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
						var ds1:Dataset = view.tools.firstSet.selectedItem as Dataset;
						var ds2:Dataset = view.tools.secondSet.selectedItem as Dataset;
						var ds3:Dataset = view.tools.thirdSet.selectedItem as Dataset;
						var ds4:Dataset = view.tools.fourthSet.selectedItem as Dataset;
						var year:String = '';
						if(view.tools.yearSlider.dataProvider) {
							year =  view.tools.yearSlider.dataProvider.getItemAt(view.tools.yearSlider.selectedIndex).year;
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
			if(util.view is IGraphView) {
				this.view.graphView = util.view as IGraphView;
				view.graphHolder.addElement(util.view as Group);
				if(model.client.datasets.length > 3) {
					var ds1:Dataset = view.tools.firstSet.selectedItem =  view.tools.firstSet.dataProvider.getItemAt(1) as Dataset;
					var ds2:Dataset = view.tools.secondSet.selectedItem =  view.tools.secondSet.dataProvider.getItemAt(2) as Dataset;
					var ds3:Dataset = view.tools.thirdSet.selectedItem =  view.tools.thirdSet.dataProvider.getItemAt(3) as Dataset;

					view.tools.fourthSet.dataProvider = fourthSetList;
					var ds4:Dataset = view.tools.fourthSet.selectedItem = regionOption;
					
					var d:ArrayCollection = model.normalizeData(view.filterTools.selectedCategories,ds1,ds2,ds3,ds4);		
					view.graphView.visualize(model.maxRadius,d,ds1,ds2,ds3,ds4);
					datasetids = ds1.id.toString()+','+ds2.id.toString()+','+ds3.id.toString();
					checkNotes();
					this.formatVizTitle(view.graphView.datasets);
				}
				view.filterTools.optionsPanel.maxRadiusSlider.value = 25;
				view.filterTools.optionsPanel.xrayToggle.selected = true;	
			}
		}
		private function handleMapLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IMapView) {
				view.mapHolder.addElement(util.view as Group);
				this.view.mapView = util.view as IMapView;
				util.view.addEventListener('vizComplete',handleVizComplete,false,0,true);
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
					
					for (var i:int=0;i<dataset.years.length;i++) {
						years.addItem(new Year(dataset.years[i],dataset.years[i].split('_').join('-'),1)); 
					}
					view.tools.yearSlider.dataProvider = years;
				}
				view.filterTools.numericFilter.dataset = dataset;
				datasetids = dataset.id.toString();
				checkNotes();	
			}
			else {
				dataset = model.client.datasets.getItemAt(0) as Dataset;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.TOGGLE_PROGRESS,false));
				view.mapView.visualize(dataset);
				view.tools.thirdSet.selectedItem = dataset;
				view.filterTools.numericFilter.dataset = null;
			}
			this.formatVizTitle(view.mapView.datasets);
			eventMap.mapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleStackChange,IndexChangedEvent);
		}
		private function handleClusterLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IClusterView) {
				this.view.clusterView = util.view as IClusterView;
				view.clusterHolder.addElement(util.view as Group);

				var dataset1:Dataset = model.client.qualityDatasets.length > 1? model.client.qualityDatasets.getItemAt(1) as Dataset:model.client.qualityDatasets.getItemAt(0) as Dataset;
				var dataset2:Dataset = model.client.quantityDatasets.length > 1? model.client.quantityDatasets.getItemAt(1) as Dataset:model.client.quantityDatasets.getItemAt(0) as Dataset
				view.tools.thirdSet.selectedItem = dataset1;
				view.tools.fourthSet.selectedItem = dataset2;
				view.clusterView.visualize(dataset1,dataset2);
				
				if(dataset1.id != -1) 
					view.filterTools.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(dataset1.optionsArray));					
				else 
					view.filterTools.categoriesPanel.continentList.dataProvider = model.regions;							
				
				if(dataset2.id > 0) 
					view.filterTools.numericFilter.dataset = dataset2;
				else
					view.filterTools.numericFilter.dataset = null;
				datasetids = dataset1.id.toString()+','+dataset2.id.toString();	
				checkNotes();
			

				this.formatVizTitle(view.clusterView.datasets);
				view.filterTools.optionsPanel.maxRadiusSlider.value = 100;
				view.filterTools.optionsPanel.xrayToggle.selected = true;
			}			

		}
		private function handleTwitterLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is ITwitterView) {
				util.view.addEventListener('vizComplete',handleVizComplete,false,0,true);
				util.view.addEventListener('vizStarted',handleVizComplete,false,0,true);
				view.twitterView = util.view as ITwitterView;
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
					view.tools.twitterOptionsBtn.selected = false;
				else
					view.filterTools.topics.topicsList.dataProvider = new ArrayCollection(view.twitterView.topics);
			}
		}
		private function restoreViewOptions(viz:IVisualizer):void {
			var arr:Array = viz.viewOptions;
			view.filterTools.optionsPanel.maxRadiusSlider.value = arr[0];
			view.filterTools.optionsPanel.xrayToggle.selected = arr[1];
			//view.tools.yearSlider.selectedItem
		}
		

		private var currentEvent:Event;

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
					
					if(datasets[0].id != -1) {
						if(datasets[1].id != -1) {	
							t += " vs ";
							t +=  datasets[1].name + ",";
						}
						else {
							t +=  datasets[1].name;
						}
					}
					
					if(datasets[2].id != -1)
						t += " sized by " + datasets[2].name;
					
					if(datasets[3].id > 0)
						t += ", grouped by " + datasets[3].name;
					else if(datasets[3].id == -2)
						t += ", grouped by region";
				break;
				
				case model.TWITTER_INDEX:
				break;
			}
			view.vizTitle.text = t;
		}
	}
}
