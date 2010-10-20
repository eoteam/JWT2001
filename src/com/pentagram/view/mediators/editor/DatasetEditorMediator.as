package com.pentagram.view.mediators.editor
{
	import com.pentagram.model.AppModel;
	import com.pentagram.view.components.editor.DatasetEditor;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class DatasetEditorMediator extends Mediator
	{
		[Inject]
		public var appModel:AppModel;
		
		[Inject]
		public var view:DatasetEditor;
		
		public override function onRegister():void {
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_CREATED,handleDatasetCreated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_DELETED,handleDatasetDeleted,EditorEvent);
		}
	}
}