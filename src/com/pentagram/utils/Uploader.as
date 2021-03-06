package com.pentagram.utils
{
	import com.pentagram.controller.Constants;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="uploadCompleteData", type="flash.events.DataEvent")]
	public class Uploader extends EventDispatcher
	{	
		private var baseURL:String;
		
		public function Uploader(url:String):void {
			baseURL = url;
		}
		
		public function upload(file:File,dir:String=''):void {
			var url:String = baseURL + "?directory="+dir+"&fileType=images";
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
		public function upload2(file:FileReference,dir:String=''):void {
			var url:String = baseURL + "?directory="+dir+"&fileType=file";
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.method = URLRequestMethod.POST;  
			file.addEventListener(ProgressEvent.PROGRESS, uploadProgress);
			file.addEventListener(Event.COMPLETE, uploadComplete);
			file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA , uploadServerData);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadError);
			file.addEventListener(HTTPStatusEvent.HTTP_STATUS, uploadError);	
			file.addEventListener(IOErrorEvent.IO_ERROR, uploadError);
			file.upload(urlRequest, "Filedata"); 
			//currentFile = file;
		}
		private function uploadProgress(event:ProgressEvent):void  {
			dispatchEvent(event);
		}
		private function uploadServerData(event:DataEvent):void {
			trace(event.data);
			dispatchEvent(event); 
			var file:File = event.target as File;
			file.removeEventListener(ProgressEvent.PROGRESS, uploadProgress);
			file.removeEventListener(Event.COMPLETE, uploadComplete);
			file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA , uploadServerData);
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadError);
			file.removeEventListener(HTTPStatusEvent.HTTP_STATUS, uploadError);	
			file.removeEventListener(IOErrorEvent.IO_ERROR, uploadError);
		}
		private  function uploadError(event:Event):void {
			var errorStr:String = event.toString();
			trace("Error uploading: " + event.target.nativePath + "\n  Message: " + errorStr);
			dispatchEvent(event);
		} 
		private function uploadComplete(event:Event):void {

		}                 
	}
}