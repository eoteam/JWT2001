package com.pentagram.main.mediators
{
	import com.pentagram.controller.Constants;
	import com.pentagram.main.windows.CountriesWindow;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.MimeType;
	import com.pentagram.utils.Uploader;
	
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class CountriesMediator extends Mediator
	{
		[Inject]
		public var view:CountriesWindow;
		
		[Inject]
		public var model:AppModel;
		
		override public function onRegister():void {
			view.countryList.dataProvider = new ArrayCollection(model.countries.source);
			view.continentList.dataProvider = model.regions;
			
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSave,false,0,true);
			view.logoHolder.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDragDrop,false,0,true);
			view.changeImageBtn.addEventListener(MouseEvent.CLICK,handleChangeImage,false,0,true);
		}
		private var fileToUpload:File;
		private function onDragDrop(event:NativeDragEvent):void {
			if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				trace("file:///" + File(files[0]).nativePath); 
				if(MimeType.getMimetype(File(files[0]).extension) == MimeType.IMAGE) {
					view.logo.source = "file:///" + File(files[0]).nativePath;
					fileToUpload = files[0] as File;
				}
				else {
					
				}
			}
		}
		private function handleChangeImage(event:MouseEvent):void {
			fileToUpload = File.desktopDirectory; 
			fileToUpload.addEventListener(Event.SELECT, onFileLoad); 
			fileToUpload.browse([new FileFilter("Images", ".gif;*.jpeg;*.jpg;*.png")]); 
		}
		private function onFileLoad(event:Event):void {
			view.logo.source = "file:///" + fileToUpload.nativePath;
		}
		private function handleSave(event:MouseEvent):void {
			var uploader:Uploader = new Uploader();
			uploader.addEventListener(Event.COMPLETE, uploadCompleteHandler);
			uploader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			uploader.addFile(fileToUpload);       
			var newURL:String = Constants.UPLOAD_URL + "?directory=/flags/&fileType=images";
			uploader.start(newURL);       
		}
		private function progressHandler(event:ProgressEvent):void
		{
			trace("Progress", event.bytesLoaded, event.bytesTotal);
		}
		private function uploadCompleteHandler(event:Event):void
		{
			trace("complete");
		}     
	}
}