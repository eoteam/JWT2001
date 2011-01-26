package com.pentagram.utils
{
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.filesystem.*;
	import flash.filesystem.FileStream;
	import flash.net.*;
	import flash.utils.ByteArray;  
	public class Uploader extends EventDispatcher
	{
		private var files:Array;
		private var totalSize:uint;
		private var uploadedSoFar:uint;
		private var currentFile:File;
		public var url:String;
		public function Uploader():void
		{
			totalSize = 0;
			files = new Array();
		}
		/*
		* This function starts the uploading process of all files that were not uploaded yet
		*/
		public function addFile(file:File):void 
		{
			files.push(file);
		}
		
		/*
		* Starts uploading the files.
		*/
		public function start(url:String):void
		{
			this.url = url;
			uploadedSoFar = 0;
			for (var i:uint; i < files.length; i++)
			{
				var file:File = files[i] as File;
				totalSize += file.size;
			}
			uploadNext();
		}
		/*
		* Upload the next file in the list. Only one file is uploaded at a time.
		*/
		private function uploadNext():void
		{
			if (files.length > 0)
			{
				currentFile = files.pop() as File;
				uploadFile(currentFile);
			}
			else
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		/*
		* Calls the upload() method for one File object
		*/
		private function uploadFile(file:File):void
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
		
		/*
		* ProgressEvent callback.
		*/
		private function uploadProgress(event:ProgressEvent):void 
		{
			var uploadedAmt:uint = uploadedSoFar + event.bytesLoaded;
			var progressEvt:ProgressEvent = event;
			event.bytesLoaded = uploadedAmt;
			event.bytesTotal = totalSize;
			dispatchEvent(event);
		}
		
		/*
		* Server data callback.
		*/
		private function uploadServerData(event:DataEvent):void
		{
			trace(event.data);
		}
		/*
		* Complete callback.
		*/
		private function uploadComplete(event:Event):void
		{
			uploadedSoFar += currentFile.size;
			var newLocation:File = currentFile.parent.resolvePath("uploaded/" + currentFile.name);
			uploadNext();
		}
		/*
		* Upload error callback.
		*/
		private function uploadError(event:Event):void
		{
			var errorStr:String = event.toString();
			trace("Error uploading: " + currentFile.nativePath + "\n  Message: " + errorStr);
			dispatchEvent(event);
		}                    
	}
}