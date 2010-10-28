package com.pentagram.view.mediators.editor
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.view.components.editor.DatasetCreator;
	import com.pentagram.view.event.ViewEvent;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class DatasetCreatorMediator extends Mediator
	{
		[Inject]
		public var view:DatasetCreator;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function onRegister():void {
			eventMap.mapListener(view,ViewEvent.DATASET_CREATOR_COMPLETE,handleDatasetCreatorComplete,ViewEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_CREATED,handleCancel,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.CANCEL,handleCancel,EditorEvent);
			view.titlePrompt.sets = appModel.selectedClient.datasets.source;
		}
		private function handleCancel(event:Event):void {
			view.reset();
		}
		private function handleDatasetCreatorComplete(event:ViewEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_DATASET,event.args[0] as Dataset));
		}
	}
}