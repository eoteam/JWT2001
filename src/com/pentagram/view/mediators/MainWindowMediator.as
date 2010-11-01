package com.pentagram.view.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.OpenWindowsProxy;
	import com.pentagram.model.vo.Client;
	import com.pentagram.view.components.MainWindow;
	import com.pentagram.view.components.windows.LoginWindow;
	import com.pentagram.view.event.ViewEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class MainWindowMediator extends Mediator
	{
		[Inject]
		public var view:MainWindow;
		
		[Inject]
		public var appModel:AppModel;
		
		[Inject]
		public var windowModel:OpenWindowsProxy;
		
		//private var selectedClient:Client;
		public override function onRegister():void
		{
			eventMap.mapListener( eventDispatcher, VisualizerEvent.CLIENT_DATA_LOADED, handleClientDataLoaded, VisualizerEvent);
			eventMap.mapListener( eventDispatcher, VisualizerEvent.LOAD_SEARCH_VIEW, loadSearchView, VisualizerEvent);
		
			eventMap.mapListener(view.loginBtn,MouseEvent.CLICK,handleUserButton,MouseEvent,false,0,true);
			
			eventMap.mapListener( eventDispatcher, ViewEvent.CLIENT_SELECTED, handleClientSelected, ViewEvent);
			eventMap.mapListener( eventDispatcher, ViewEvent.SHELL_LOADED, handleShellLoaded, ViewEvent);
		}
		private function handleClientSelected(event:ViewEvent):void
		{
			view.currentState = view.visualizerAndLoadingState.name;	
			//selectedClient = event.args[0] as Client;
		}
		private function handleShellLoaded(event:ViewEvent):void
		{
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
		}
		private function handleClientDataLoaded(event:VisualizerEvent):void
		{
			view.currentState = view.visualizerAndLoadedState.name;
		}
		private function loadSearchView(event:VisualizerEvent):void
		{
			view.currentState = view.searchState.name;
		}
		private function handleUserButton(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,windowModel.LOGIN_WINDOW)); 
		}		
	}
}