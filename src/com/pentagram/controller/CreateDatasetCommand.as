package com.pentagram.controller
{
	import com.pentagram.event.EditorEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class CreateDatasetCommand extends Command
	{
		[Inject]
		public var appModel:AppModel;
		
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var event:EditorEvent;
		
		override public function execute():void {
			var dataset:Dataset = event.args[0] as Dataset;
			
			appService.createDataset(dataset);
			appService.addHandlers(handleDatasetCreated);
		}
		private function handleDatasetCreated(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;
			if(result) {
				var msg:Array = result.message.split(',');
				var dataset:Dataset = this.event.args[0] as Dataset;
				dataset.contentid = appModel.selectedClient.id;
				dataset.createdby = dataset.modifiedby = appModel.user.id;
				dataset.tablename = msg[1];
				dataset.id = msg[0];
				dataset.loaded = true;
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_CREATED,dataset));
			}
		}
	}
}