package com.pentagram.view.mediators
{
	import com.pentagram.event.AppEvent;
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.view.MainView;
	import com.pentagram.view.components.LoginWindow;
	import com.pentagram.view.event.ViewEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class MainViewMediator extends Mediator
	{
		[Inject]
		public var view:MainView;
		
		[Inject]
		public var appModel:AppModel;
		
		private var loginWindow:LoginWindow;
		//private var selectedClient:Client;
		public override function onRegister():void
		{
			eventMap.mapListener( eventDispatcher, VisualizerEvent.CLIENT_DATA_LOADED, handleClientDataLoaded, VisualizerEvent);
			eventMap.mapListener( eventDispatcher, VisualizerEvent.LOAD_SEARCH_VIEW, loadSearchView, VisualizerEvent);
			
			eventMap.mapListener( eventDispatcher, AppEvent.SHOW_LOGIN_WINDOW, handleStartLogin, AppEvent);
			eventMap.mapListener( eventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			view.loginBtn.addEventListener(MouseEvent.CLICK,handleUserButton,false,0,true);
			
			eventMap.mapListener( eventDispatcher, ViewEvent.CLIENT_SELECTED, handleClientSelected, ViewEvent);
			eventMap.mapListener( eventDispatcher, ViewEvent.SHELL_LOADED, handleShellLoaded, ViewEvent);
		}
		private function handleClientSelected(event:ViewEvent):void
		{
			view.currentState = view.visualizerAndLoadingState.name;	
			//selectedClient = event.args[0] as Client;
		}
		private function handleShellLoaded(event:ViewEvent):void
		{
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
		}
		private function handleClientDataLoaded(event:VisualizerEvent):void
		{
			view.currentState = view.visualizerAndLoadedState.name;
		}
		private function loadSearchView(event:VisualizerEvent):void
		{
			view.currentState = view.searchState.name;
		}
		private function handleStartLogin(event:AppEvent):void
		{
			if(!loginWindow) {
				loginWindow = new LoginWindow();
				loginWindow.addEventListener(FlexEvent.CONTENT_CREATION_COMPLETE,handleCreationComplete,false,0,true);
				loginWindow.resizable = false;
				loginWindow.gripper = null;
				loginWindow.addEventListener(Event.CLOSE,handleLoginWindowClose);
				loginWindow.width = 400;
				loginWindow.height = 200;
				loginWindow.open();	
			}
			else {
				loginWindow.activate();
			}
		}
		private function handleLoginWindowClose(event:Event):void {
			loginWindow = null;
		}
		private function handleCreationComplete(event:FlexEvent):void
		{
			if(appModel.user != null)
				loginWindow.didLogin(appModel.user);
			loginWindow.loginBtn.addEventListener(MouseEvent.CLICK,handleLoginClick);
			loginWindow.logoutBtn.addEventListener(MouseEvent.CLICK,handleLogoutClick);
		}
		private function handleLoginClick(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGIN,loginWindow.unInput.text,loginWindow.pwInput.text));
		}
		private function handleLogoutClick(event:MouseEvent):void
		{
			loginWindow.didLogout();
			appModel.user = null;
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGGEDOUT ));
		}
		private function handleLogin(event:AppEvent):void
		{
			loginWindow.didLogin(appModel.user);
		}
		private function handleUserButton(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.SHOW_LOGIN_WINDOW));
		}		
	}
}