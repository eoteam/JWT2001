package com.pentagram.utils
{
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	public class Downloader extends EventDispatcher
	{
		private var _fileLoader:URLLoader;
		private var _fileName:String;
		private var _fileURL:String;
		private var _downloadsDirectory:File;
		private var baseURL:String
		
		public function Downloader(url:String):void {
			baseURL = url;
			_downloadsDirectory =  File.userDirectory;
			_downloadsDirectory.addEventListener(Event.SELECT, handleFolderSelection);
		}
		
		public function download(fileURL:String,fileName:String=null):void {
			_fileURL = fileURL;
			if(fileName)
				_fileName = fileName;
			else
				_fileName = fileURL.substr(fileURL.lastIndexOf("/")+1);
			

			_downloadsDirectory.browseForDirectory("Please select a directory...");
			
		}
		private function handleFolderSelection(event:Event):void {
			_fileLoader = new URLLoader();
			_fileLoader.dataFormat = URLLoaderDataFormat.BINARY;
			configureListeners();
			_fileLoader.load(new URLRequest(_fileURL));
		}
		private function completeHandler(event:Event):void
		{
			trace("completeHandler: " + event);
			
			var fileData:ByteArray = event.target.data;
			var dlFile:File = File.userDirectory;
			dlFile = _downloadsDirectory.resolvePath(_fileName);
			var dlFileStream:FileStream = new FileStream();
			dlFileStream.open(dlFile, FileMode.WRITE);
			dlFileStream.writeBytes(fileData);
			dlFileStream.close();
			trace("fileSaved: "+dlFile.nativePath);
			configureListeners(true);
			dispatchEvent(event);
		}
		
		private function httpResponseStatusHandler(event:HTTPStatusEvent):void 
		{
//			trace("httpResponseStatusHandler: " + event);
//			trace("\tstatus: " + event.status);
//			trace("\tresponseURL: " + event.responseURL);
//			trace("\tresponseHeaders:");
//			for each(var responseHeaderObject:Object in event.responseHeaders)
//			{
//				trace("\t\tname: " + responseHeaderObject.name + ", Value: " + responseHeaderObject.value);
//			}
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void 
		{
			//trace("httpStatusHandler: " + event);
			//trace("\tstatus: " + event.status);
		}
		
		private function cancelHandler(event:Event):void 
		{
			trace("cancelHandler: " + event);
			configureListeners(true);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + event);
			configureListeners(true);
		}
		
		private function openHandler(event:Event):void 
		{
			//trace("openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void 
		{
			//trace("progressHandler bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
			dispatchEvent(event);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
			configureListeners(true);
		}
		
		
		//-------------------------------------------
		// Helpers
		//-------------------------------------------
		
		private function configureListeners(remove:Boolean = false):void 
		{
			if(!remove)
			{
				_fileLoader.addEventListener(Event.COMPLETE, completeHandler);
				_fileLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusHandler);
				_fileLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				_fileLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_fileLoader.addEventListener(Event.OPEN, openHandler);
				_fileLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				_fileLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			}
			else
			{
				_fileLoader.removeEventListener(Event.COMPLETE, completeHandler);
				_fileLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusHandler);
				_fileLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				_fileLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_fileLoader.removeEventListener(Event.OPEN, openHandler);
				_fileLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
				_fileLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			}
		}
		
		
		
	}
}