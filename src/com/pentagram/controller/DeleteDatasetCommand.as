package com.pentagram.controller
{
	import com.pentagram.event.EditorEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class DeleteDatasetCommand extends Command
	{
		[Inject]
		public var appModel:AppModel;
		
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var event:EditorEvent;
		
		override public function execute():void {
			var dataset:Dataset = event.args[0] as Dataset;
			appService.deleteDataset(dataset);
			appService.addHandlers(handleDatasetDeleted);
		}
		private function handleDatasetDeleted(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;
			if(result.success) {
				var dataset:Dataset = this.event.args[0] as Dataset;
				appModel.selectedClient.datasets.removeItem(dataset);
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_DELETED));
			}
		}
	}
}