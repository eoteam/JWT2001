package com.pentagram.view.mediators
{
	import com.pentagram.controller.Constants;
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.vo.Client;
	import com.pentagram.view.components.ClientBarView;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ClientBarMediator extends Mediator
	{
		[Inject]
		public var view:ClientBarView;
		
		override public function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
		}
		private function handleClientLoaded(event:VisualizerEvent):void
		{
			var client:Client = event.args[0] as Client;
			view.logo.source = Constants.FILES_URL+client.thumbs;
			trace(Constants.FILES_URL+client.thumbs);
		}
	}
}