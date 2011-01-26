package com.pentagram.services.interfaces
{
	import flash.filesystem.File;

	public interface IFileService extends IService
	{
		function upload(file:File):void;
		
		function addFileToDatabase(file:Object):void;
		
		function addFileToContent(contentid:int,mediaid:int):void;
	}
}