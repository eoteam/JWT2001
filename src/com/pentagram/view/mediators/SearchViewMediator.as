package com.pentagram.view.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.view.event.ViewEvent;
	import com.pentagram.view.components.SearchView;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	
	public class SearchViewMediator extends Mediator
	{
		[Inject]
		public var view:SearchView;

		[Inject]
		public var appModel:AppModel;
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent);
			view.searchInput.addEventListener(CustomEvent.SELECT,handleSelect,false,0,true);
		}
		private function handleStartUp(event:AppEvent):void
		{
			view.searchInput.visible = true;
			view.searchInput.dataProvider = appModel.clients.source;
		}
		private function handleSelect(event:CustomEvent):void
		{
			if(appModel.selectedClient != event.data as Client) {
				appModel.selectedClient = event.data as Client;
				eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.CLIENT_SELECTED));
			}
			view.searchInput.text = '';
		}
	}
}