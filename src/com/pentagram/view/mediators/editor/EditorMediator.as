package com.pentagram.view.mediators.editor
{
	import com.pentagram.event.EditorEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.view.components.editor.EditorMainView;
	import com.pentagram.view.components.editor.OverviewEditor;
	import com.pentagram.view.event.ViewEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class EditorMediator extends Mediator
	{
		[Inject]
		public var  view:EditorMainView;
		
		[Inject]
		public var appModel:AppModel;
		
		[Inject]
		public var appService:IAppService;
		
		public override function onRegister():void {	
		
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DATA_UPDATED,handleClientDataUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_CREATED,handleDatasetCreated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_DELETED,handleDatasetDeleted,EditorEvent);
			eventMap.mapListener(view,'datasetState',handleDatasetState,Event,false,0,true);
		
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSaveChanges,false,0,true);
			view.cancelBtn.addEventListener(MouseEvent.CLICK,handleCancelChange,false,0,true);			
		}
		
		private function handleSaveChanges(event:MouseEvent):void {
			if(view.currentState == "overview") {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_CLIENT_DATA,view.client));
			}
			else {
				
			}
		}
		private function handleCancelChange(event:MouseEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CANCEL));
		}
		private function handleDelete(event:MouseEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DELETE_DATASET,view.dataSetList.selectedItem));
		}
		private function handleDatasetState(event:Event):void {
			view.deleteBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
		}
		private function handleClientDataUpdated(event:EditorEvent):void {
			view.statusModule.updateStatus("Client Data Updated");
		}
		private function handleDatasetCreated(event:EditorEvent):void {
			var dataset:Dataset = event.args[0] as Dataset;
			view.currentState = view.datasetState.name;
			view.dataSetList.selectedItem = dataset;
			view.statusModule.updateStatus("Data Set Created");
		}
		private function handleDatasetDeleted(event:EditorEvent):void {
			view.statusModule.updateStatus("Data Set Deleted");
			if(appModel.selectedClient.datasets.length == 0) {
				view.datasetEditor.dataset = null;
				view.currentState = view.overviewState.name;
			}
			else
				view.dataSetList.selectedIndex = 0;
		}
		
	}
}