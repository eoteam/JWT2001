package com.pentagram.main.mediators
{
	import com.adobe.serialization.json.JSON;
	import com.pentagram.controller.Constants;
	import com.pentagram.main.windows.BatchUploader;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Country;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.utils.Uploader;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Mediator;

	public class BatchUploaderMediator extends Mediator
	{
		[Inject]
		public var view:BatchUploader;

		[Inject]
		public var model:AppModel;
		
		[Inject]
		public var appService:IAppService;
		
		private var uploader:Uploader;
		private var index:int = 0;
		override public function onRegister():void {
			view.uploadBtn.addEventListener(MouseEvent.CLICK,startUpload);
			uploader = new Uploader(Constants.UPLOAD_URL);
			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			uploader.addEventListener(ProgressEvent.PROGRESS,handleUploadProgress);
		}
		private function startUpload(event:Event):void{
			view.currentState = "uploading";  
			uploadNext();
		}
		private function uploadNext():void {
			index++; 
			if(index < view.selectedFiles.length) {
				
				uploader.upload2(FileReference(view.selectedFiles[index]), view.path.text);
			}
			else {
				view.progressText2.text = view.progressText1.text = view.completedFilesList.text = '';
				view.uploadProgress = 0;
				view.currentState = "browse";
				view.selectedFiles = null;   
			}
		}
		private function handleUploadComplete(event:DataEvent):void {
			view.uploadProgress = 1;
			var file:Object = JSON.decode(event.data);
			//Country(view.countryList.selectedItem).thumb = Constants.FILES_URL + "/flags/"+file.name;
			appService.addFileToDatabase(file,"/flags/");
			appService.addHandlers(fileAdded);
		}
		private function handleUploadProgress(event:ProgressEvent):void {
			view.uploadProgress = event.bytesLoaded/event.bytesTotal;
			view.progressText1.text = "Uploading " + (index+1).toString() + " of " + (view.selectedFiles.length+1).toString(); 
			view.progressText2.text = Math.round(event.bytesLoaded/event.bytesTotal).toString()+"%";  
		}
		private function fileAdded(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				view.completedFilesList.text += FileReference(view.selectedFiles[index]).name + "\n";
				uploadNext();
			}
			
		}
	}
}