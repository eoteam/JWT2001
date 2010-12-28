package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.LoginPanel;
	import com.pentagram.main.windows.LoginWindow;
	import com.pentagram.model.AppModel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	
	import org.robotlegs.core.IMediator;
	import org.robotlegs.mvcs.Mediator;
	
	public class LoginPanelMediator extends Mediator implements IMediator
	{
				
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher; 
		
		[Inject]
		public var view:LoginPanel;
		
		[Inject]
		public var model:InstanceModel;
		
		override public function onRegister():void
		{
			//eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event,false,0,true);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, logout, AppEvent);
			
			eventMap.mapListener(view.loginBtn, MouseEvent.CLICK,handleLoginClick,MouseEvent,false,0,true);
			eventMap.mapListener(view,StateChangeEvent.CURRENT_STATE_CHANGE,handleStateChanged,StateChangeEvent,false,0,true);

			if(model.user != null)
					view.didLogin(model.user);
		}
		private function handleLoginClick(event:MouseEvent):void
		{
			appEventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGIN,view.unInput.text,view.pwInput.text));
		}
		private function handleLogoutClick(event:MouseEvent):void
		{
			logout();
			appEventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGGEDOUT));
		}
		
		private function handleLogin(event:AppEvent):void
		{
			view.didLogin(model.user);
		}
		private function logout(event:AppEvent=null):void {
			view.didLogout();
			model.user = null;
		}
		private function handleStateChanged(event:StateChangeEvent):void {
			if(view.currentState == "loggedin") {
					eventMap.mapListener(view.logoutBtn,MouseEvent.CLICK,handleLogoutClick,MouseEvent,false,0,true);
			}	
		}
	}
}