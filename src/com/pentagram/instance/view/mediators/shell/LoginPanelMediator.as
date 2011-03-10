package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.LoginPanel;
	import com.pentagram.main.event.ViewEvent;
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
			//eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, logout, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGIN_ERROR, handleError, AppEvent);
			
			eventMap.mapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			
			eventMap.mapListener(view.loginBtn, MouseEvent.CLICK,handleLoginClick,MouseEvent);
			eventMap.mapListener(view,StateChangeEvent.CURRENT_STATE_CHANGE,handleStateChanged,StateChangeEvent);

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
					eventMap.mapListener(view.logoutBtn,MouseEvent.CLICK,handleLogoutClick,MouseEvent);
			}	
		}
		private function handleError(event:AppEvent):void {
			view.errorMsg.visible = true; 
		}
		private function handleCleanup(event:ViewEvent):void {
			this.mediatorMap.removeMediator(this);
		}
		override public function onRemove():void {
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGGEDOUT, logout, AppEvent);
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGIN_ERROR, handleError, AppEvent);
			
			eventMap.unmapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			
			eventMap.unmapListener(view.loginBtn, MouseEvent.CLICK,handleLoginClick,MouseEvent);
			eventMap.unmapListener(view,StateChangeEvent.CURRENT_STATE_CHANGE,handleStateChanged,StateChangeEvent);
			
			eventMap.unmapListener(view.logoutBtn,MouseEvent.CLICK,handleLogoutClick,MouseEvent);
			
			view.user = null;
			
			super.onRemove();
		}
	}
}