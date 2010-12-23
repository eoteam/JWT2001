package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IDatasetService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class DeleteDatasetCommand extends Command
	{
		[Inject]
		public var model:InstanceModel;
		
		[Inject]
		public var service:IDatasetService;
		
		[Inject]
		public var event:EditorEvent;
		
		override public function execute():void {
			var dataset:Dataset = event.args[0] as Dataset;
			service.deleteDataset(dataset);
			service.addHandlers(handleDatasetDeleted);
		}
		private function handleDatasetDeleted(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;
			if(result.success) {
				var dataset:Dataset = this.event.args[0] as Dataset;
				model.client.datasets.removeItem(dataset);
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_DELETED));
			}
		}
	}
}