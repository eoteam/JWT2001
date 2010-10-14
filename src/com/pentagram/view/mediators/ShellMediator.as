package com.pentagram.view.mediators
{
	import com.pentagram.controller.Constants;
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.vo.Client;
	import com.pentagram.view.components.ClientBarView;
	import com.pentagram.view.components.ShellView;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ShellMediator extends Mediator
	{
		[Inject]
		public var view:ShellView;
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.LOAD_SEARCH_VIEW,handleLoadSearchView,VisualizerEvent);
		}
		private function handleClientLoaded(event:VisualizerEvent):void
		{
			var client:Client = event.args[0] as Client;
			view.client = client;
			trace(Constants.FILES_URL+client.thumbs);
		}
		private function handleLoadSearchView(event:VisualizerEvent):void
		{
			view.client = null;
			view.clientBar.infoBtn.selected = false;
			view.clientBar.currentState = view.clientBar.closedState.name;
		}
	}
}