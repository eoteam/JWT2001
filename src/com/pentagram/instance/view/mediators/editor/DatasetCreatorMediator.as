package com.pentagram.instance.view.mediators.editor
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.editor.DatasetCreator;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.main.event.ViewEvent;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class DatasetCreatorMediator extends Mediator
	{
		[Inject]
		public var view:DatasetCreator;
		
		[Inject]
		public var model:InstanceModel;
		
		override public function onRegister():void {
			eventMap.mapListener(view,ViewEvent.DATASET_CREATOR_COMPLETE,handleDatasetCreatorComplete,ViewEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_CREATED,handleCancel,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.CANCEL,handleCancel,EditorEvent);
			view.titlePrompt.sets = model.client.datasets.source;
		}
		private function handleCancel(event:Event):void {
			view.reset();
		}
		private function handleDatasetCreatorComplete(event:ViewEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_DATASET,event.args[0] as Dataset));
		}
	}
}