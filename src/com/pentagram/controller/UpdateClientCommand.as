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
		private var count:int;
		private var total:int;
		
		override public function execute():void {

			fileToUpload = event.args[0] as File;
			client = event.args[1] as Client;
			uploader = event.args[2] as Uploader;
			
			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			
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
				count++;
				checkCount();
			}	
		}
		private function handleClientSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				client.modifiedProps = [];
				client.modified = false;
				count++;
				checkCount();
			}
		}
		private function checkCount():void {
			if(count == total) {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CLIENT_DATA_UPDATED));
			}
		}
	}
}