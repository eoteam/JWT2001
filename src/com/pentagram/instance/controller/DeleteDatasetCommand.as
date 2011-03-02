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
		
		private var sets:Vector.<Object>;
		private var counter:int;
		private var total:int;	
		override public function execute():void {
			sets = event.args[0] as Vector.<Object>;
			for each(var dataset:Dataset in sets) {
				if(dataset.id != -1) {
					service.deleteDataset(dataset);
					service.addHandlers(handleDatasetDeleted);
					service.addProperties("dataset",dataset);
					total++;
				}
			}
		}
		private function handleDatasetDeleted(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;
			if(result.success) {
				counter++;
				
				var dataset:Dataset = event.token.dataset;
				model.client.datasets.removeItem(dataset);
				if(dataset.type == 1) 
					model.client.quantityDatasets.removeItem(dataset);
				else
					model.client.qualityDatasets.removeItem(dataset);
				if(counter == total) {
					sets = null;
					eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_DELETED));
				}
			}
		}
	}
}