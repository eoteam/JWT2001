package com.pentagram.controller
{
	import com.adobe.serialization.json.JSON;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.model.AppModel;
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

	
	public class CreateClientCommand extends Command
	{
		
		[Inject]
		public var model:AppModel;
		
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var clientService:IClientService;
		
		
		[Inject]
		public var event:EditorEvent;
		
		private var fileToUpload:File;
		private var client:Client;
		private var uploader:Uploader;
		private var count:int;
		private var total:int = 1;
		
		override public function execute():void {
			fileToUpload = event.args[0] as File;
			client = event.args[1] as Client;
			uploader = event.args[2] as Uploader;
			
			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			
			clientService.createClient(client,model.user.id	);
			clientService.addHandlers(handleClientCreated);	
		}
		private function handleUploadComplete(event:DataEvent):void {
			var file:Object = JSON.decode(event.data);
			uploader.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			client.thumb = Constants.FILES_URL + "/clients/"+file.name; 
			appService.addFileToDatabase(file,"/clients/");
			appService.addHandlers(fileAdded);
			count++;
			checkCount();
		}
		private function fileAdded(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				var mediaid:int = Number(result.message);
				appService.addFileToContent(client.id,mediaid,'thumb');
				appService.addHandlers(contentmediaAdded);
			}
		}
		private function contentmediaAdded(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				count++;
				checkCount();
			}	
		}
		private function handleClientCreated(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				count++;
				client.id = Number(result.message);
				if(fileToUpload) {
					uploader.upload(fileToUpload,"/clients/");
					total++;
				}
				else
					checkCount();
			}			
		}
		private function checkCount():void {
			if(count == total) {
				//country.region.countries.addItem(client);
				this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CLIENT_CREATED));
			}
		}
	}
}