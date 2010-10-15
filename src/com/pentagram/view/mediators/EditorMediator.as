package com.pentagram.view.mediators
{
	import com.pentagram.model.AppModel;
	import com.pentagram.view.components.OverviewEditor;
	import com.pentagram.view.components.EditorMainView;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class EditorMediator extends Mediator
	{
		[Inject]
		public var  view:EditorMainView;
		
		[Inject]
		public var appModel:AppModel;
		
		
		public override function onRegister():void
		{
			view.overviewEditor.countries = appModel.countries.source;
			view.overviewEditor.continentList.dataProvider = appModel.continents;
			view.overviewEditor.client = view.client;
		}
		private function passCountries(event:Event):void
		{
			trace(event.target.toString());
		}
	}
}