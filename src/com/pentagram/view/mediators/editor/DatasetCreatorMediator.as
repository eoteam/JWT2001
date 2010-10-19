package com.pentagram.view.mediators.editor
{
	import com.pentagram.event.EditorEvent;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.view.components.editor.DatasetCreator;
	import com.pentagram.view.event.ViewEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class DatasetCreatorMediator extends Mediator
	{
		[Inject]
		public var view:DatasetCreator;
		
		override public function onRegister():void {
			eventMap.mapListener(view,ViewEvent.DATASET_CREATOR_COMPLETE,handleDatasetCreatorComplete,ViewEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.CANCEL,handleCancel,EditorEvent);
		}
		private function handleCancel(event:EditorEvent):void {
			view.reset();
		}
		private function handleDatasetCreatorComplete(event:ViewEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_DATA_SET,event.args[0] as Dataset));
		}
	}
}