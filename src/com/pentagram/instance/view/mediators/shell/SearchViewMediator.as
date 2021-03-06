package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.Search;
	import com.pentagram.events.ViewEvent;
	import com.pentagram.model.vo.Client;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	
	public class SearchViewMediator extends Mediator
	{
		[Inject]
		public var view:Search;

		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;  
		
		public override function onRegister():void
		{
			//eventMap.mapListener(eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);			
			
			eventMap.mapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			
			eventMap.mapListener(view.searchInput,CustomEvent.SELECT,handleSelect,CustomEvent);
			eventMap.mapListener(view.searchInput,FlexEvent.ENTER,searchInput_enterHandler,FlexEvent);			
			eventMap.mapListener(view,'notfoundState',handleNotfoundState,Event);
				
			view.searchInput.visible = true;	
			view.searchInput.dataProvider = model.clients.source;
			if(model.user) {
				view.loggedIn = true;
			}
		}

		private function handleSelect(event:CustomEvent):void
		{
			if(model.client != event.data as Client) {
				model.client = event.data as Client;
			}
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.CLIENT_SELECTED));
			view.searchInput.text = '';
		}
		private function searchInput_enterHandler(event:FlexEvent):void
		{
			if(view.searchInput.list.dataProvider.length == 0)
				view.currentState = "notfound";
			else 
				view.searchInput.list.selectedIndex = 0;
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
			eventMap.mapListener(view.newClientBtn,MouseEvent.CLICK,handleNewClientBtn,MouseEvent);

		}
		private function handleNewClientBtn(event:MouseEvent):void {
			appEventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,"clientWindow"));
		}
		private function handleCleanup(event:ViewEvent):void {
			this.mediatorMap.removeMediator(this);
		}
		override public function onRemove():void {
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);			
			
			eventMap.unmapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			
			eventMap.unmapListener(view.searchInput,CustomEvent.SELECT,handleSelect,CustomEvent);
			eventMap.unmapListener(view.searchInput,FlexEvent.ENTER,searchInput_enterHandler,FlexEvent);			
			eventMap.unmapListener(view,'notfoundState',handleNotfoundState,Event);
			
			eventMap.unmapListener(view.newClientBtn,MouseEvent.CLICK,handleNewClientBtn,MouseEvent);
	
			if(view.searchInput)
				view.searchInput.dataProvider = null;			
			trace("Search Mediator Released");
			super.onRemove();
		}
	}
}