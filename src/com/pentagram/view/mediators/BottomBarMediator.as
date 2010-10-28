package com.pentagram.view.mediators
{
	import com.pentagram.controller.Constants;
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.OpenWindowsProxy;
	import com.pentagram.model.vo.Client;
	import com.pentagram.view.components.BottomBarView;
	import com.pentagram.view.event.ViewEvent;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	
	public class BottomBarMediator extends Mediator
	{
		[Inject]
		public var view:BottomBarView;
		
		[Inject]
		public var appModel:AppModel;
		
		[Inject]
		public var windowModel:OpenWindowsProxy;
		
		override public function onRegister():void
		{
			view.searchInput.dataProvider = appModel.clients.source;
			view.searchInput.addEventListener(CustomEvent.SELECT,handleSelect,false,0,true);
			view.homeButton.addEventListener(MouseEvent.CLICK,handleHomeButton,false,0,true);
			view.loginBtn.addEventListener(MouseEvent.CLICK,handleUserButton,false,0,true);
		}
		private function handleHomeButton(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.LOAD_SEARCH_VIEW));
		}
		private function handleUserButton(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,windowModel.LOGIN_WINDOW)); 
		}
		private function handleSelect(event:CustomEvent):void
		{
			if(appModel.selectedClient != event.data as Client) {
				appModel.selectedClient = event.data as Client;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
			}
			view.searchInput.text = '';
		}
	}
}