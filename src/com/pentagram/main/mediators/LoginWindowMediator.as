package com.pentagram.main.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.main.windows.LoginWindow;
	import com.pentagram.model.AppModel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.robotlegs.core.IMediator;
	import org.robotlegs.mvcs.Mediator;
	
	public class LoginWindowMediator extends Mediator implements IMediator
	{
		public function LoginWindowMediator()
		{
			super();
		}
		
		[Inject]
		public var view:LoginWindow;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function onRegister():void
		{
			eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event,false,0,true);
			eventMap.mapListener(eventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			
			eventMap.mapListener(view.loginBtn, MouseEvent.CLICK,handleLoginClick,MouseEvent,false,0,true);
			eventMap.mapListener(view.logoutBtn,MouseEvent.CLICK,handleLogoutClick,MouseEvent,false,0,true);

			if(appModel.user != null)
				view.didLogin(appModel.user);
		}
		protected function handleLoginClick(event:MouseEvent):void
		{
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGIN,view.unInput.text,view.pwInput.text));
		}
		protected function handleLogoutClick(event:MouseEvent):void
		{
			view.didLogout();
			appModel.user = null;
			eventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGGEDOUT));
		}
		protected function handleWindowClose(event:Event):void
		{
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.WINDOW_CLOSED, view.id));
			mediatorMap.removeMediator(this);
		}
		protected function handleLogin(event:AppEvent):void
		{
			view.didLogin(appModel.user);
		}
	}
}