package com.pentagram.instance.view.mediators.editor
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.editor.DatasetEditor;
	import com.pentagram.model.AppModel;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class DatasetEditorMediator extends Mediator
	{
		[Inject]
		public var model:InstanceModel;
		
		[Inject]
		public var view:DatasetEditor;
		
		public override function onRegister():void {
			//eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_CREATED,handleDatasetCreated,EditorEvent);
			//eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_DELETED,handleDatasetDeleted,EditorEvent);
			//view.dataset = appModel.selectedSet;
			view.client = model.client;
			eventMap.mapListener(eventDispatcher,EditorEvent.UPDATE_CLIENT_DATA,saveDataset,EditorEvent);
			view.dataset = model.selectedSet;
			
			view.generateDataset();
		}
		public function saveDataset(event:Event):void {
			
		}
	}
}