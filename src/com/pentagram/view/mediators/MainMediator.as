package com.pentagram.view.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.view.components.MainWindow;
	
	import org.robotlegs.mvcs.Mediator;
	import org.robotlegs.core.IMediator;
	
	public class MainMediator extends Mediator implements IMediator
	{
		[Inject]
		public var view:Main;
		
		[Inject]
		public var appModel:AppModel;
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, AppEvent.STARTUP_COMPLETE, handleStartUp, AppEvent);
			//view.searchInput.addEventListener(CustomEvent.SELECT,handleSelect,false,0,true);
		}
		private function handleStartUp(event:AppEvent):void
		{
			var window:MainWindow = new MainWindow();
			mediatorMap.createMediator(window);
			window.open();
			window.orderToFront();
		}
	}
}