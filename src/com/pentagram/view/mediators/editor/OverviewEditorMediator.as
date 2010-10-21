package com.pentagram.view.mediators.editor
{
	import com.pentagram.event.EditorEvent;
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Continent;
	import com.pentagram.view.components.editor.OverviewEditor;
	import com.pentagram.view.event.ViewEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.DropDownEvent;
	
	public class OverviewEditorMediator extends Mediator
	{
		[Inject]
		public var view:OverviewEditor;
		
		[Inject]
		public var appModel:AppModel;
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher,EditorEvent.CANCEL,handleCancel,EditorEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientSelected,VisualizerEvent);
			view.client = appModel.selectedClient;
			view.countryList.autoCompleteDataProvider = appModel.countries.source;
			view.continentList.dataProvider = appModel.continents;	
			view.continentList.addEventListener(DropDownEvent.CLOSE,handleContinentSelection,false,0,true);
		}
		private function handleCancel(event:EditorEvent):void {
			
		}
		private function handleClientSelected(event:VisualizerEvent):void {
			view.client = appModel.selectedClient;
		}
		private function handleContinentSelection(event:DropDownEvent):void {
			var continent:Continent = event
		}
	}
}