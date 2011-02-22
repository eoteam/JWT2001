package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
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
					dataset.range = dataset.years.join(',');
				var country:Country;
				var row:DataRow;
				var i:int=0;
				for (i=0;i<dataset.optionsArray.length;i++)  {
					dataset.optionsArray[i].color = model.colors[i];
				}
				if(dataset.rows.length == 0 ) {
					if(dataset.time == 1) {
						for each(country in model.client.countries.source) {
							row = new DataRow();
							row.name = country.name;
							row.dataset = dataset;
							row.country = country;
							for (i=0;i<dataset.years.length;i++) {
								row[dataset.years[i]] = dataset.type == 1 ? 0:'';
							}
							dataset.rows.addItem(row);
						}
					}				
					else {
						for each(country in model.client.countries.source) {
							row = new DataRow();
							row.name = country.name;
							row.country = country;
							row.value = dataset.type == 1 ? 0:'';
							row.dataset = dataset;
							dataset.rows.addItem(row);
						}
					}
					eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_CREATED,dataset));
				}
				else {
					this.dispatch(new EditorEvent(EditorEvent.DUMP_DATASET_DATA,dataset));
				}
				if(dataset.type == 1)
					model.client.quantityDatasets.addItem(dataset);
				else
					model.client.qualityDatasets.addItem(dataset);
				model.client.datasets.addItem(dataset);
				
			}
		}
	}
}