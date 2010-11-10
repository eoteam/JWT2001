package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.controller.Constants;
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.model.vo.Year;
	import com.pentagram.instance.view.shell.ClientBarView;
	import com.pentagram.instance.view.shell.ShellView;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.User;
	import com.pentagram.util.ViewUtils;
	import com.pentagram.view.event.ViewEvent;
	
	import flare.vis.data.Data;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.events.IndexChangedEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.DropDownEvent;
	
	public class ShellMediator extends Mediator
	{
		[Inject]
		public var view:ShellView;
		
		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;  
		
		private var editorMapped:Boolean = false;
		private var yearTimer:Timer;
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.LOAD_SEARCH_VIEW,handleLoadSearchView,VisualizerEvent);
			
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			
			view.mainStack.addEventListener(IndexChangedEvent.CHANGE,handleStackChange);
			view.thirdSet.addEventListener(DropDownEvent.CLOSE,handleSecondSet,false,0,true);
			//mediatorMap.createMediator(view.bottomBarView);
			if(model.user)
				view.currentState = view.loggedInState.name;
			else
				view.currentState = view.loggedOutState.name;
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.SHELL_LOADED));
			
			view.playBtn.addEventListener(MouseEvent.CLICK,handlePlayButton);
			
			var years:ArrayList = new ArrayList();
			for (var i:int=1980;i<=2010;i++) {
				years.addItem(new Year(i,1));
			}
			view.yearSlider.dataProvider = years;
			yearTimer = new Timer(500);
			yearTimer.addEventListener(TimerEvent.TIMER,handleTimer);
		}
		private function handleStackChange(event:IndexChangedEvent):void {
			if(event.newIndex == 1 && !editorMapped) {
				editorMapped = true;
				//mediatorMap.createMediator(view.editorView);	
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
			view.currentState = view.loggedInState.name;
		}
		private function handleLogout(event:AppEvent):void
		{
			model.user = null;
			view.currentState = view.loggedOutState.name;
		}	
		private function handlePlayButton(event:Event):void {
			if(view.playBtn.selected) {
				if(view.yearSlider.selectedIndex == view.yearSlider.dataProvider.length-1)
						view.yearSlider.selectedIndex = 0;
				yearTimer.start();
				view.playBtn.label = "Stop";
				model.updateData(view.graphView.data,view.yearSlider.dataProvider.getItemAt(0).year as int,view.firstSet.selectedItem,view.secondSet.selectedItem,view.thirdSet.selectedItem);
				view.graphView.update();
			}
			else {
				yearTimer.stop();
				view.playBtn.label = "Play";
			}
		}
		private function handleTimer(event:TimerEvent):void {
			view.yearSlider.selectedIndex++;
			if(view.yearSlider.selectedIndex == view.yearSlider.dataProvider.length-1) {
				yearTimer.stop();
			}
			else {
				model.updateData(view.graphView.data,view.yearSlider.dataProvider.getItemAt(view.yearSlider.selectedIndex).year as int,view.firstSet.selectedItem,view.secondSet.selectedItem,view.thirdSet.selectedItem);
			}
		}
		
		private function handleSecondSet(event:Event):void {
			var d:Array = model.normalizeData(view.firstSet.selectedItem,view.secondSet.selectedItem,view.thirdSet.selectedItem);	
			view.graphView.visualize(d,view.firstSet.selectedItem.name,view.secondSet.selectedItem.name,view.thirdSet.selectedItem.name);
		}
			
	}
}