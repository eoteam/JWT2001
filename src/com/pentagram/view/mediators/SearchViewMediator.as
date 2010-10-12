package com.pentagram.view.mediators
{
	import com.pentagram.event.AppEvent;
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
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
			eventMap.mapListener( eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent);
			view.searchInput.addEventListener(CustomEvent.SELECT,handleSelect);
		}
		private function handleStartUp(event:AppEvent):void
		{
			view.searchInput.visible = true;
			view.searchInput.dataProvider = appModel.clients.source;
		}
		private function handleSelect(event:CustomEvent):void
		{
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED,event.data as Client));
		}
	}
}