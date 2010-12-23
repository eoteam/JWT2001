package com.pentagram.main.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.main.windows.ClientListWindow;
	import com.pentagram.main.windows.LoginWindow;
	import com.pentagram.model.AppModel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.robotlegs.core.IMediator;
	import org.robotlegs.mvcs.Mediator;
	
	
	public class ClientWindowMediator extends Mediator
	{
		[Inject]
		public var view:ClientListWindow;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function onRegister():void
		{
			eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event,false,0,true);
		}
		protected function handleWindowClose(event:Event):void
		{
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.WINDOW_CLOSED, view.id));
			mediatorMap.removeMediator(this);
		}
	}
}