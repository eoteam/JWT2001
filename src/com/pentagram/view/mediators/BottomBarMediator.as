package com.pentagram.view.mediators
{
	import com.pentagram.controller.Constants;
	import com.pentagram.event.AppEvent;
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.view.components.BottomBarView;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class BottomBarMediator extends Mediator
	{
		[Inject]
		public var view:BottomBarView;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function onRegister():void
		{
			view.searchInput.dataProvider = appModel.clients.source;	
			view.homeButton.addEventListener(MouseEvent.CLICK,handleHomeButton);
			view.loginBtn.addEventListener(MouseEvent.CLICK,handleUserButton);
		}
		private function handleHomeButton(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.LOAD_SEARCH_VIEW));
		}
		private function handleUserButton(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.SHOW_LOGIN_WINDOW));
		}
	}
}