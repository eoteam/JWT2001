package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.services.interfaces.IDatasetService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class CreateDatasetCommand extends Command
	{
		[Inject]
		public var model:InstanceModel;
		
		[Inject]
		public var service:IDatasetService;
		
		[Inject]
		public var event:EditorEvent;
		
		override public function execute():void {
			var dataset:Dataset = event.args[0] as Dataset;
			service.createDataset(dataset);
			service.addHandlers(handleDatasetCreated);
		}
		private function handleDatasetCreated(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;
			if(result.success) {
				var msg:Array = result.message.split(',');
				var dataset:Dataset = this.event.args[0] as Dataset;
				dataset.contentid = model.client.id;
				dataset.createdby = dataset.modifiedby = model.user.id;
				dataset.tablename = msg[1];
				dataset.id = msg[0];
				dataset.loaded = true;
				if(dataset.time)
					dataset.range = dataset.years[0].toString()+','+dataset.years[1].toString();
				var country:Country;
				var row:DataRow;
				if(dataset.time == 1) {
					for each(country in model.client.countries.source) {
						row = new DataRow();
						row.name = country.name;
						row.dataset = dataset;
						for (var i:int=dataset.years[0];i<=dataset.years[1];i++) {
							row[i.toString()] = dataset.type == 1 ? 0:'';
						}
						dataset.rows.addItem(row);
					}
				}
				
				else {
					for each(country in model.client.countries.source) {
						row = new DataRow();
						row.name = country.name;
						row.value = dataset.type == 1 ? 0:'';
						row.dataset = dataset;
						dataset.rows.addItem(row);
					}
				}
				model.client.datasets.addItem(dataset);
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_CREATED,dataset));
			}
		}
	}
}