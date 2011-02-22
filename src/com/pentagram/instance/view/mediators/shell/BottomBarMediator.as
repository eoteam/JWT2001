package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.BottomBar;
	import com.pentagram.model.vo.Client;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	
	public class BottomBarMediator extends Mediator
	{
		[Inject]
		public var view:BottomBar;
		
		[Inject]
		public var model:InstanceModel;
			
//		
//		[Inject(name="ApplicationEventDispatcher")]
//		public var appEventDispatcher:EventDispatcher;   
		
		override public function onRegister():void
		{
			view.searchInput.dataProvider = model.clients.source;
			view.searchInput.addEventListener(CustomEvent.SELECT,handleSelect,false,0,true);
			view.searchInput.addEventListener(FlexEvent.ENTER,searchInput_enterHandler,false,0,true);
			view.homeButton.addEventListener(MouseEvent.CLICK,handleHomeButton,false,0,true);
			view.loginBtn.addEventListener(MouseEvent.CLICK,handleUserButton,false,0,true);
		}
		private function handleHomeButton(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.LOAD_SEARCH_VIEW));
		}
		private function handleUserButton(event:MouseEvent):void
		{
			//appEventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,model.LOGIN_WINDOW)); 
		}
		private function handleSelect(event:CustomEvent):void
		{
			if(model.client != event.data as Client) {
				model.client = event.data as Client;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
			}
			view.searchInput.text = '';
		}
		protected function searchInput_enterHandler(event:FlexEvent):void
		{
			if(view.searchInput.list.dataProvider.length == 0)
				view.currentState = "notfound";
			else {
				view.searchInput.list.selectedIndex = 0;
			}
		} 
	}
}