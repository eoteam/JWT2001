package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.model.vo.Year;
	import com.pentagram.instance.view.shell.ShellView;
	import com.pentagram.instance.view.visualizer.IGraphView;
	import com.pentagram.instance.view.visualizer.IMapView;
	import com.pentagram.instance.view.visualizer.ModuleUtil;
	import com.pentagram.model.vo.User;
	import com.pentagram.view.event.ViewEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.events.IndexChangedEvent;
	import mx.events.StateChangeEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.Group;
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
		
		private var yearTimer:Timer;
		private var firstPass:Boolean = true;

		private var loaders:Array = [];
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.LOAD_SEARCH_VIEW,handleLoadSearchView,VisualizerEvent);
			
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent,false,0,true);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent,false,0,true);
			
			//view.mainStack.addEventListener(IndexChangedEvent.CHANGE,handleStackChange,false,0,true);
			view.visualizerArea.addEventListener(IndexChangedEvent.CHANGE,handleStackChange,false,0,true);
			view.tools.initTools();
		

			view.tools.thirdSet.addEventListener(DropDownEvent.CLOSE,handleSecondSet,false,0,true);	
			view.tools.yearSlider.addEventListener(IndexChangeEvent.CHANGE,handleYearSelection,false,0,true);
			view.tools.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE,handleToolsStateChange);

			//mediatorMap.createMediator(view.bottomBarView);
			if(model.user)
				view.currentState = view.loggedInState.name;
			else
				view.currentState = view.loggedOutState.name;
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.SHELL_LOADED));
			
			view.tools.playBtn.addEventListener(MouseEvent.CLICK,handlePlayButton,false,0,true);
			
			var years:ArrayList = new ArrayList();
			for (var i:int=1980;i<=2010;i++) {
				years.addItem(new Year(i,1));
			}
			view.tools.yearSlider.dataProvider = years;
			yearTimer = new Timer(2000);
			yearTimer.addEventListener(TimerEvent.TIMER,handleTimer);
		}
		private function handleStackChange(event:IndexChangedEvent):void {
			var util:ModuleUtil;
			if(event.newIndex == 1 && view.mapView == null) {
				util = new ModuleUtil();
				util.addEventListener("moduleLoaded",handleMapLoaded);
				util.loadModule("com/pentagram/instance/view/visualizer/MapView.swf");	
				loaders.push(util);
			}
			else if(event.newIndex == 2 && view.graphView == null) {
				util = new ModuleUtil();
				util.addEventListener("moduleLoaded",handleGraphLoaded);
				util.loadModule("com/pentagram/instance/view/visualizer/GraphView.swf");
				loaders.push(util);
			}
		}
		private function handleClientLoaded(event:VisualizerEvent):void
		{
			view.client = model.client;
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
			view.currentState = view.loggedInState.name;
		}
		private function handleLogout(event:AppEvent):void
		{
			model.user = null;
			view.currentState = view.loggedOutState.name;
		}	
		private function handleToolsStateChange (event:StateChangeEvent):void  {
			if(view.tools.currentState == "graph") {
				view.tools.firstSet.addEventListener(DropDownEvent.CLOSE,handleSecondSet,false,0,true);
				view.tools.secondSet.addEventListener(DropDownEvent.CLOSE,handleSecondSet,false,0,true);
				
				view.tools.fourthSet.addEventListener(DropDownEvent.CLOSE,handleSecondSet,false,0,true);
				view.tools.maxRadiusSlider.addEventListener(Event.CHANGE ,handleMaxRadius,false,0,true);
			}
		}
			
		private function handlePlayButton(event:Event):void {
			view.graphView.continous = view.tools.playBtn.selected;
			if(view.tools.playBtn.selected) {
				if(view.tools.yearSlider.selectedIndex == view.tools.yearSlider.dataProvider.length-1)
						view.tools.yearSlider.selectedIndex = 0;
				yearTimer.start();
				view.tools.playBtn.label = "Stop";
				model.updateData(view.graphView.visdata,
								 view.tools.yearSlider.dataProvider.getItemAt(0).year as int,
								 view.tools.firstSet.selectedItem,
								 view.tools.secondSet.selectedItem,
								 view.tools.thirdSet.selectedItem);
				view.graphView.update();
			}
			else {
				yearTimer.stop();
				view.tools.playBtn.label = "Play";
			}
		}
		private function handleTimer(event:TimerEvent):void {
			view.tools.yearSlider.selectedIndex++;
			if(view.tools.yearSlider.selectedIndex == view.tools.yearSlider.dataProvider.length-1) {
				yearTimer.stop();
			}
			else {
				model.updateData(view.graphView.visdata,
								 view.tools.yearSlider.dataProvider.getItemAt(view.tools.yearSlider.selectedIndex).year as int,
					view.tools.firstSet.selectedItem,
					view.tools.secondSet.selectedItem,
					view.tools.thirdSet.selectedItem,
					view.tools.fourthSet.selectedItem);
				view.graphView.update();
			}
		}
		private function handleYearSelection(event:IndexChangeEvent):void {
			if(!firstPass) {
				model.updateData(view.graphView.visdata,view.tools.yearSlider.dataProvider.getItemAt(view.tools.yearSlider.selectedIndex).year as int,
				view.tools.firstSet.selectedItem,
				view.tools.secondSet.selectedItem,
				view.tools.thirdSet.selectedItem,
				view.tools.fourthSet.selectedItem);
				view.graphView.update();
			}
		}
		private function handleSecondSet(event:Event):void {
			switch(view.visualizerArea.selectedIndex) {
				case 0:
				break;
				case 1:
					if(view.tools.thirdSet.selectedItem) 
						view.mapView.visualize(view.tools.thirdSet.selectedItem);
				break;
				case 2:
					if(view.tools.firstSet.selectedItem && view.tools.secondSet.selectedItem) {
						var d:Array = model.normalizeData(view.tools.firstSet.selectedItem,
							view.tools.secondSet.selectedItem,
							view.tools.thirdSet.selectedItem,
							view.tools.fourthSet.selectedItem);	
						view.graphView.visualize(d,
							view.tools.firstSet.selectedItem,
							view.tools.secondSet.selectedItem,
							view.tools.thirdSet.selectedItem,
							view.tools.fourthSet.selectedItem);
						firstPass = false;
					}
				break;
			}
			
		}
		private function handleMaxRadius(event:Event):void {
			view.graphView.updateMaxRadius(view.tools.maxRadiusSlider.value);
		}
		private function handleGraphLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IGraphView) {
				this.view.graphView = util.view as IGraphView;
				view.graphHolder.addElement(util.view as Group);
			}
		}
		private function handleMapLoaded(event:Event):void {
			var util:ModuleUtil  = event.target as ModuleUtil;
			if(util.view is IMapView) {
				this.view.mapView = util.view as IMapView;
				view.mapHolder.addElement(util.view as Group);
			}
		}

			
	}
}