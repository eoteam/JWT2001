package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.SearchView;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.main.event.ViewEvent;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	import org.robotlegs.utilities.modular.mvcs.ModuleMediator;
	
	public class SearchViewMediator extends Mediator
	{
		[Inject]
		public var view:SearchView;

		[Inject]
		public var model:InstanceModel;
		
		public override function onRegister():void
		{
			//eventMap.mapListener(eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent);
			view.searchInput.addEventListener(CustomEvent.SELECT,handleSelect,false,0,true);
			view.searchInput.visible = true;
			view.searchInput.dataProvider = model.clients.source;
		}

		private function handleSelect(event:CustomEvent):void
		{
			if(model.client != event.data as Client) {
				model.client = event.data as Client;
				eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.CLIENT_SELECTED));
			}
			view.searchInput.text = '';
		}
	}
}