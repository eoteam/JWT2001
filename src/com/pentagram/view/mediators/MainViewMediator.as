package com.pentagram.view.mediators
{
	import com.pentagram.event.AppEvent;
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.view.MainView;
	import com.pentagram.view.components.LoginWindow;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class MainViewMediator extends Mediator
	{
		[Inject]
		public var view:MainView;
		
		public override function onRegister():void
		{
			eventMap.mapListener( eventDispatcher, VisualizerEvent.CLIENT_SELECTED, handleClientSelected, VisualizerEvent);
			eventMap.mapListener( eventDispatcher, VisualizerEvent.CLIENT_DATA_LOADED, handleClientDataLoaded, VisualizerEvent);
			eventMap.mapListener( eventDispatcher, VisualizerEvent.LOAD_SEARCH_VIEW, loadSearchView, VisualizerEvent);
			eventMap.mapListener( eventDispatcher, AppEvent.START_LOGIN, handleStartLogin, AppEvent);
		}
		private function handleClientSelected(event:VisualizerEvent):void
		{
			view.currentState = view.visualizerAndLoadingState.name;	
		}
		private function handleClientDataLoaded(event:VisualizerEvent):void
		{
			view.currentState = view.visualizerAndLoadedState.name;
		}
		private function loadSearchView(event:VisualizerEvent):void
		{
			view.currentState = view.searchState.name;
		}
		private function handleStartLogin(event:AppEvent):void
		{
			var loginWindow:LoginWindow = new LoginWindow();
			loginWindow.width = 500;
			loginWindow.height = 350;
			loginWindow.open();	
		}
	}
}