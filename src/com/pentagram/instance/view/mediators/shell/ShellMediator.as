package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.model.vo.Year;
	import com.pentagram.instance.view.shell.ShellView;
	import com.pentagram.instance.view.visualizer.interfaces.IClusterView;
	import com.pentagram.instance.view.visualizer.interfaces.IGraphView;
	import com.pentagram.instance.view.visualizer.interfaces.IMapView;
	import com.pentagram.instance.view.visualizer.interfaces.IVisualizer;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Region;
	import com.pentagram.model.vo.User;
	import com.pentagram.utils.ModuleUtil;
	import com.pentagram.utils.ViewUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.IndexChangedEvent;
	import mx.events.StateChangeEvent;
	import mx.utils.ArrayUtil;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
	import spark.components.NavigatorContent;
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	
	public class ShellMediator extends Mediator
	{
		[Inject]
		public var view:ShellView;
		
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
						
			view.visualizerArea.addEventListener(IndexChangedEvent.CHANGE,handleStackChange,false,0,true);			
			view.stage.addEventListener(FullScreenEvent.FULL_SCREEN,handleFullScreen,false,0,true);
			
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
			
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.SHELL_LOADED));
		}

		
		private function handleStackChange(event:IndexChangedEvent):void {
			var util:ModuleUtil;
			if(event.newIndex == 1){
				restoreDatasets(view.mapView);
				view.mapView.updateSize();
				
			}
			else if(event.newIndex == 2){
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
			else if(event.newIndex == 0){
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
				case 0:
					view.clusterView.visualize(event.args[0],event.args[1]);
				break;
				case 1:
					view.mapView.visualize(event.args[0]);
				break;
				case 2:
					view.graphView.visualize(model.maxRadius,event.args[0],event.args[1],event.args[2],event.args[3],event.args[4]);
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
				case 0:
					view.clusterView.updateYear(event.args[0]);
				break;
				case 1:
					view.mapView.updateYear(event.args[0]);
					break;
				case 2:	
					model.updateData2(view.graphView.visdata,event.args[0],event.args[1],event.args[2],event.args[3],event.args[4]);
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
					if(view.visualizerArea.selectedIndex == 1)
						view.mapView.toggleMap(value);
				break;
				case 'maxRadius':
					if(view.visualizerArea.selectedIndex == 2) {
					var ds1:Dataset = view.tools.firstSet.selectedItem as Dataset;
					var ds2:Dataset = view.tools.secondSet.selectedItem as Dataset;
					var ds3:Dataset = view.tools.thirdSet.selectedItem as Dataset;
					var ds4:Dataset = view.tools.fourthSet.selectedItem as Dataset;
					var year:int =  view.tools.yearSlider.dataProvider.getItemAt(view.tools.yearSlider.selectedIndex).year as int;
					model.updateData2(view.graphView.visdata,year,ds1,ds2,ds3,ds4);
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
				//var ds4:Dataset = view.tools.firstSet.dataProvider.getItemAt(0) as Dataset;
				var d:ArrayCollection = model.normalizeData2(ds1,ds2,ds3,null);
				
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
				view.mapView.visualize(model.client.quantityDatasets.getItemAt(0) as Dataset);
				view.tools.thirdSet.selectedItem = model.client.quantityDatasets.getItemAt(0) as Dataset;
			}
		}
		private function handleClusterLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IClusterView) {
				this.view.clusterView = util.view as IClusterView;
				view.clusterHolder.addElement(util.view as Group);
			}			
		}
		private function handleFullScreen(event:FullScreenEvent):void{
			view.currentVisualizer.updateSize();
		}
	}
}