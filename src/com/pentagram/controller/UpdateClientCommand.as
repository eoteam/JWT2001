package com.pentagram.controller
{
	import com.adobe.serialization.json.JSON;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.services.interfaces.IClientService;
	import com.pentagram.utils.Uploader;
	
	import flash.events.DataEvent;
	import flash.filesystem.File;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;

	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	public class UpdateClientCommand extends Command
	{

		[Inject]
		public var service:IClientService;
		
		[Inject]
		public var event:EditorEvent;
		
		[Inject]
		public var appService:IAppService;
		
		private var fileToUpload:File;
		private var client:Client;
		private var uploader:Uploader;
		private var counter:int;
		private var total:int;
		
		override public function execute():void {

			fileToUpload = event.args[0] as File;
			client = event.args[1] as Client;
			uploader = event.args[2] as Uploader;
			
			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			var dataset:Dataset
			if(fileToUpload) {
				appService.removeClientThumb(client.id,"thumb");
				appService.addHandlers(handleRemoveComplete);
				total++;
			}
			if(client.modified) {
				service.saveClientInfo(client);
				service.addHandlers(handleClientSaved);
				total++;
			}
//			if(client.newCountries.length > 0) {
//				service.addClientCountries(client,client.newCountries);
//				service.addHandlers(handleAddClientCountry);
//				total++;
//				for each(dataset in client.datasets.source) {
//					if(dataset.id != -1) {
//						service.addDatasetCountries(dataset,client.newCountries);
//						service.addProperties('dataset',dataset);
//						service.addHandlers(handleAddDatasetCountry);
//						total++;
//					}
//				}
//				
//			}
//			if(client.deletedCountries.length > 0) {
//				service.removeClientCountries(client,client.deletedCountries);
//				service.addHandlers(handleRemoveClientCountry);
//				total++;
//				for each(dataset in client.datasets.source) {
//					service.removeDatasetCountries(dataset, client.deletedCountries);
//					service.addProperties('dataset',dataset);
//					service.addHandlers(handleRemoveDatasetCountry);
//					total++;
//				}
//			}
		}
		private function handleUploadComplete(event:DataEvent):void {
			var file:Object = JSON.decode(event.data);
			uploader.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			client.thumb = Constants.FILES_URL + "/clients/"+file.name; 
			appService.addFileToDatabase(file,"/clients/");
			appService.addHandlers(fileAdded);
		}
		private function fileAdded(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				var mediaid:int = Number(result.message);
				appService.addFileToContent(client.id,mediaid,'thumb');
				appService.addHandlers(contentmediaAdded);
			}
		}
		private function handleRemoveComplete(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				uploader.upload(fileToUpload,"/clients/");
			}
		}
		private function contentmediaAdded(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				counter++;
				checkCount();
			}	
		}
		private function handleClientSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				client.modifiedProps = [];
				client.modified = false;
				counter++;
				checkCount();
			}
		}
//		private function handleAddClientCountry(event:ResultEvent):void {
//			client.newCountries.removeAll();				
//			counter++;
//			checkCount();
//		}
//		private function handleRemoveClientCountry(event:ResultEvent):void {
//			client.deletedCountries.removeAll();				
//			counter++;
//			checkCount();
//		}	
//		private function handleAddDatasetCountry(event:ResultEvent):void {
//			var rows:Array = event.token.results as Array;
//			var dataset:Dataset = event.token.dataset as Dataset;
//			for each(var item:Object in rows) {
//				for each(var country:Country in client.countries.source) {
//					if(country.id == item.countryid) {
//						var row:DataRow = new DataRow();
//						row = new DataRow();
//						row.name = country.name;
//						//						row.xcoord = country.xcoord/849;
//						//						row.ycoord = -country.ycoord/337;
//						row.country = country;
//						row.id = Number(item.id);
//						row.color = country.region.color;
//						row.dataset = dataset;
//						if(dataset.time == 1) {
//							for(var i:int=0;i<dataset.years.length;i++) {
//								row[dataset.years[i]] = dataset.type == 1 ? 0:'';
//							}
//						}
//						else
//							row.value = dataset.type == 1 ? 0:'';
//						dataset.rows.addItem(row);
//						break;
//					}
//				}			
//			}
//			counter++;
//			checkCount();
//		}
//		private function handleRemoveDatasetCountry(event:ResultEvent):void {
//			var dataset:Dataset = event.token.dataset as Dataset;
//			var cids:Array = event.token.params.idvalues.toString().split(',');
//			for each(var id:int in cids) {
//				for each(var row:DataRow in dataset.rows) {
//					if(row.country.id == id) {
//						dataset.rows.removeItemAt(dataset.rows.getItemIndex(row));
//						break;
//					}
//				}
//			}
//			counter++;
//			checkCount();
//		}
		private function checkCount():void {
			if(counter == total) {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CLIENT_DATA_UPDATED));
			}
		}
	}
}