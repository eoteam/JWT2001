package com.pentagram.view.mediators.editor
{
	import com.pentagram.event.EditorEvent;
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
			eventMap.mapListener(eventDispatcher,EditorEvent.CANCEL,handleCancel,EditorEvent);
			view.countryList.autoCompleteDataProvider = appModel.countries.source;
			view.continentList.dataProvider = appModel.continents;	
		}
		private function handleCancel(event:EditorEvent):void {
			
		}
	}
}