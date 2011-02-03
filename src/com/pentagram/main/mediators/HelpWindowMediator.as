package com.pentagram.main.mediators
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.main.windows.HelpWindow;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class HelpWindowMediator extends Mediator
	{
		[Inject]
		public var view:HelpWindow;
		
		override public function onRegister():void
		{
			eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event,false,0,true);
		}
		private function handleWindowClose(event:Event):void {
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.WINDOW_CLOSED, view.id));
			mediatorMap.removeMediator(this);
		}
	}
}