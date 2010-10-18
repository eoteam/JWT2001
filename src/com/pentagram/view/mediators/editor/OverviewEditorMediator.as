package com.pentagram.view.mediators.editor
{
	import com.pentagram.model.AppModel;
	import com.pentagram.view.components.editor.OverviewEditor;
	import com.pentagram.view.event.ViewEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class OverviewEditorMediator extends Mediator
	{
		[Inject]
		public var view:OverviewEditor;
		
		[Inject]
		public var appModel:AppModel;
		
		public override function onRegister():void
		{
			//eventMap.mapListener(eventDispatcher, ViewEvent.SAVE_CLIENT_OVERVIEW,handleClientSaved,ViewEvent);
			view.countryList.autoCompleteDataProvider = appModel.countries.source;
			view.continentList.dataProvider = appModel.continents;	
		}
		private function handleClientSaved(event:ViewEvent):void {
			
		}
	}
}