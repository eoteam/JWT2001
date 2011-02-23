package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IClientService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateClientCommand extends Command
	{
		[Inject]
		public var model:InstanceModel;
		
		[Inject]
		public var service:IClientService;
		
		[Inject]
		public var editorEvent:EditorEvent;
		
		private var counter:int;
		private var total:int;
		override public function execute():void {
			counter = total = 0;
			if(model.client.modified) {
				service.saveClientInfo(model.client);
				service.addHandlers(handleClientSaved);
				//appService.addProperties("client",client);
				total++;
			}
			var dataset:Dataset;
			if(model.client.newCountries.length > 0) {
				service.addClientCountries(model.client,model.client.newCountries);
				service.addHandlers(handleAddClientCountry);
				total++;
				if(editorEvent.args[0] == true) {
					for each(dataset in model.client.datasets.source) {
						service.addDatasetCountries(dataset,model.client.newCountries);
						service.addProperties('dataset',dataset);
						service.addHandlers(handleAddDatasetCountry);
						total++;
					}
				}
			}
			if(model.client.deletedCountries.length > 0) {
				service.removeClientCountries(model.client,model.client.deletedCountries);
				service.addHandlers(handleRemoveClientCountry);
				total++;
				for each(dataset in model.client.datasets.source) {
					service.removeDatasetCountries(dataset, model.client.deletedCountries);
					service.addProperties('dataset',dataset);
					service.addHandlers(handleRemoveDatasetCountry);
					total++;
				}
			}
		}
		
		private function handleClientSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				model.client.modifiedProps = [];
				counter++;
				model.client.modified = false;
				checkCount();
				//view.statusModule.updateStatus("Client Info Saved");
			}
		}
		private function handleAddClientCountry(event:ResultEvent):void {
			model.client.newCountries.removeAll();				
			counter++;
			checkCount();
		}
		private function handleRemoveClientCountry(event:ResultEvent):void {
			model.client.deletedCountries.removeAll();				
			counter++;
			checkCount();
		}	
		private function handleAddDatasetCountry(event:ResultEvent):void {
			var rows:Array = event.token.results as Array;
			var dataset:Dataset = event.token.dataset as Dataset;
			for each(var item:Object in rows) {
				for each(var country:Country in model.client.countries.source) {
					if(country.id == item.countryid) {
						var row:DataRow = new DataRow();
						row = new DataRow();
						row.name = country.name;
//						row.xcoord = country.xcoord/849;
//						row.ycoord = -country.ycoord/337;
						row.country = country;
						row.id = Number(item.id);
						row.color = country.region.color;
						row.dataset = dataset;
						if(dataset.time == 1) {
							for(var i:int=0;i<dataset.years.length;i++) {
								row[dataset.years[i]] = dataset.type == 1 ? 0:'';
							}
						}
						else
							row.value = dataset.type == 1 ? 0:'';
						dataset.rows.addItem(row);
						break;
					}
				}			
			}
			counter++;
			checkCount();
		}
		private function handleRemoveDatasetCountry(event:ResultEvent):void {
			var dataset:Dataset = event.token.dataset as Dataset;
			var cids:Array = event.token.params.idvalues.toString().split(',');
			for each(var id:int in cids) {
				for each(var row:DataRow in dataset.rows) {
					if(row.country.id == id) {
						dataset.rows.removeItemAt(dataset.rows.getItemIndex(row));
						break;
					}
				}
			}
			counter++;
			checkCount();
		}

		private function checkCount():void {
			if(counter == total) {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CLIENT_DATA_UPDATED));
			}
		}
	}
}