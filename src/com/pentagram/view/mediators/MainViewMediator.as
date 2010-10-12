package com.pentagram.view.mediators
{
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.view.MainView;
	
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
	}
}