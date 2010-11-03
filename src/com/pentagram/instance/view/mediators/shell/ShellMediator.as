package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.controller.Constants;
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.ClientBarView;
	import com.pentagram.instance.view.shell.ShellView;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.User;
	import com.pentagram.view.event.ViewEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.events.IndexChangedEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ShellMediator extends Mediator
	{
		[Inject]
		public var view:ShellView;
		
		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;  
		
		private var editorMapped:Boolean = false;
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.LOAD_SEARCH_VIEW,handleLoadSearchView,VisualizerEvent);
			
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			
			view.mainStack.addEventListener(IndexChangedEvent.CHANGE,handleStackChange);
			
			//mediatorMap.createMediator(view.bottomBarView);
			if(model.user)
				view.currentState = view.loggedInState.name;
			else
				view.currentState = view.loggedOutState.name;
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.SHELL_LOADED));
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
	}
}