package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.SearchView;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Client;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	
	public class SearchViewMediator extends Mediator
	{
		[Inject]
		public var view:SearchView;

		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;  
		
		public override function onRegister():void
		{
			//eventMap.mapListener(eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent,false,0,true);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent,false,0,true);
			view.searchInput.addEventListener(CustomEvent.SELECT,handleSelect,false,0,true);
			eventMap.mapListener(view,'notfoundState',handleNotfoundState,Event,false,0,true);

			view.searchInput.visible = true;	
			view.searchInput.dataProvider = model.clients.source;
		}

		private function handleSelect(event:CustomEvent):void
		{
			if(model.client != event.data as Client) {
				model.client = event.data as Client;
			}
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.CLIENT_SELECTED));
			view.searchInput.text = '';
		}
		private function handleLogin(event:AppEvent):void
		{
			view.loggedIn = true;
		}
		private function handleLogout(event:AppEvent):void
		{
			view.loggedIn = false;
		}	
		private function handleNotfoundState(event:Event):void {
			view.newClientBtn.addEventListener(MouseEvent.CLICK,handleNewClientBtn,false,0,true);
		}
		private function handleNewClientBtn(event:MouseEvent):void {
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,"clientWindow"));
		}
	}
}