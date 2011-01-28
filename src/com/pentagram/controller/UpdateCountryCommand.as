package com.pentagram.controller
{
	import com.adobe.serialization.json.JSON;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Country;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.utils.Uploader;
	
	import flash.events.DataEvent;
	import flash.filesystem.File;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateCountryCommand extends Command
	{
		[Inject]
		public var model:AppModel;
		
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var event:EditorEvent;
		
		private var fileToUpload:File;
		private var country:Country;
		private var uploader:Uploader;
		private var count:int;
		private var total:int;
		override public function execute():void {
			fileToUpload = event.args[0] as File;
			country = event.args[1] as Country;
			uploader = event.args[2] as Uploader;

			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);

			if(fileToUpload) {
				uploader.upload(fileToUpload,"/flags/");
				total++;
			}
			if(country.modified) {
				appService.saveCountry(country);
				appService.addHandlers(handleCountryUpdate);
				total++;
			}
		}
		private function handleUploadComplete(event:DataEvent):void {
			var file:Object = JSON.decode(event.data);
			country.thumb = Constants.FILES_URL + "/flags/"+file.name; 
			appService.addFileToDatabase(file,"/flags/");
			appService.addHandlers(fileAdded);
			count++;
			checkCount();
		}
		private function fileAdded(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				var mediaid:int = Number(result.message);
				appService.addFileToContent(country.id,mediaid);
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
		private function handleCountryUpdate(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				count++;
				checkCount();
			}			
		}
		private function checkCount():void {
			if(count == total) {
				this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.COUNTRY_UPDATED));
			}
		}
	}
}