package com.pentagram.services
{
	import com.pentagram.services.interfaces.IFileService;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import org.robotlegs.mvcs.Actor;
	
	public class FileService extends AbstractService implements IFileService
	{
		private var currentFile:File;
		private var totalSize:uint;
		private var uploadedSoFar:uint;
		
		public function uploadFile(file:File):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.method = URLRequestMethod.POST;  
			file.addEventListener(ProgressEvent.PROGRESS, uploadProgress);
			file.addEventListener(Event.COMPLETE, uploadComplete);
			file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA , uploadServerData);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadError);
			file.addEventListener(HTTPStatusEvent.HTTP_STATUS, uploadError);	
			file.addEventListener(IOErrorEvent.IO_ERROR, uploadError);
			file.upload(urlRequest, "Filedata"); 
		}
		private function uploadProgress(event:ProgressEvent):void 
		{
			var uploadedAmt:uint = uploadedSoFar + event.bytesLoaded;
			var progressEvt:ProgressEvent = event;
			event.bytesLoaded = uploadedAmt;
			event.bytesTotal = totalSize;
			//dispatchEvent(event);
		}
		private function uploadServerData(event:DataEvent):void
		{
			trace(event.data);
		}
		private function uploadComplete(event:Event):void
		{

		}
		private function uploadError(event:Event):void
		{
			var errorStr:String = event.toString();
			trace("Error uploading: " + currentFile.nativePath + "\n  Message: " + errorStr);
			dispatchEvent(event);
		}     
		public function addFileToDatabase(file:Object):void {
			
		}
		
		public  function addFileToContent(contentid:int,mediaid:int):void {
			
		}
	}
}