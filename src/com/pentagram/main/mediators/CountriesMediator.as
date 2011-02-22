package com.pentagram.main.mediators
{
	import com.pentagram.controller.Constants;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.main.windows.CountriesWindow;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.MimeType;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.utils.CSVUtils;
	import com.pentagram.utils.Downloader;
	import com.pentagram.utils.Uploader;
	
	import flash.desktop.ClipboardFormats;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.IndexChangeEvent;

	public class CountriesMediator extends Mediator
	{
		[Inject]
		public var view:CountriesWindow;
		
		[Inject]
		public var model:AppModel;

		[Inject]
		public var appService:IAppService;
		
		private var uploader:Uploader;
		private var downloader:Downloader;
		
		private var currentCountry:Country;
		private var fileToUpload:File;
		
		override public function onRegister():void {
			view.countryList.dataProvider = new ArrayCollection(model.countries.source);
			view.countryList.addEventListener(IndexChangeEvent.CHANGE,handleSelection,false,0,true);
			view.continentList.dataProvider = model.regions;
			view.addButton.addEventListener(MouseEvent.CLICK,handleAdd,false,0,true);
			view.deleteBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
			view.altDelete.addEventListener(MouseEvent.CLICK,handleAltDelete,false,0,true);
			view.deleteListBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSave,false,0,true);
			view.cancelBtn.addEventListener(MouseEvent.CLICK,handleCancel,false,0,true);
			view.logoHolder.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDragDrop,false,0,true);
			view.changeImageBtn.addEventListener(MouseEvent.CLICK,handleChangeImage,false,0,true);
			view.downloadBtn.addEventListener(MouseEvent.CLICK,handleDownload,false,0,true);
			view.altNameInput.addEventListener(FlexEvent.ENTER,handleAltName,false,0,true);
			view.errorPanel.addEventListener("okEvent",handleNotification,false,0,true);
			view.errorPanel.addEventListener("cancelEvent",handleNotification,false,0,true);
			
			this.addViewListener(ViewEvent.CLIENT_PROP_CHANGED,handlePropChange,ViewEvent);
			
			uploader = new Uploader(Constants.UPLOAD_URL);
			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			uploader.addEventListener(ProgressEvent.PROGRESS,handleUploadProgress);
			
			downloader = new Downloader(Constants.FILES_URL);
			downloader.addEventListener(Event.COMPLETE,handleUploadComplete);
			downloader.addEventListener(ProgressEvent.PROGRESS,handleUploadProgress);
			
			eventMap.mapListener(eventDispatcher,EditorEvent.COUNTRY_UPDATED,handleCountryUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.COUNTRY_CREATED,handleCountryUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.COUNTRY_DELETED,handleCountryDeleted,EditorEvent);
		}
		
		private function onDragDrop(event:NativeDragEvent):void {
			if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				if(MimeType.getMimetype(File(files[0]).extension) == MimeType.IMAGE) {
					view.logo.source = "file:///" + File(files[0]).nativePath;
					//var country:Country = view.countryList.selectedItem as Country;
					currentCountry.modified = true;
					if(currentCountry.modifiedProps.indexOf("thumb") == -1)
						currentCountry.modifiedProps.push("thumb");
					fileToUpload = files[0] as File;
				}
				else {
					
				}
			}
		}
		private function handlePropChange(event:ViewEvent):void {
			var prop:String = event.args[1] as String;
			var value:* = event.args[2];
			if(currentCountry.modifiedProps.indexOf(prop) == -1) {
				currentCountry.modifiedProps.push(prop);
			}
			currentCountry[prop] = value;
			currentCountry.modified = true;
			if(prop == "region" && view.currentState == "add") 
				view.saveBtn.enabled = true;
		}
		private function handleChangeImage(event:MouseEvent):void {
			fileToUpload = File.desktopDirectory; 
			fileToUpload.addEventListener(Event.SELECT, onFileLoad); 
			fileToUpload.browse([new FileFilter("Images", ".gif;*.jpeg;*.jpg;*.png")]); 
		}
		private function handleDownload(event:MouseEvent):void {
			downloader.download(this.currentCountry.thumb);
		}
		private function onFileLoad(event:Event):void {
			view.logo.source = "file:///" + fileToUpload.nativePath;
		}
		private function handleAltName(event:FlexEvent):void {
			if(currentCountry.alternateNames.getItemIndex(view.altNameInput.text) == -1) {
				currentCountry.alternateNames.addItem(view.altNameInput.text);
				currentCountry.altnames = CSVUtils.ArrayToCsv([currentCountry.alternateNames.source],',');	
				currentCountry.modified = true;
				model.countryNames[view.altNameInput.text] = currentCountry;
				if(currentCountry.modifiedProps.indexOf("altnames") == -1)
					currentCountry.modifiedProps.push("altnames");
			}
		}	
		private function handleAltDelete(event:MouseEvent):void {
			var items:Vector.<Object> = view.altnameList.selectedItems;
			for each(var n:String in items) {
				currentCountry.alternateNames.removeItem(n);	
				model.countryNames[n] = null;
			}
			currentCountry.altnames = CSVUtils.ArrayToCsv([currentCountry.alternateNames.source],',');	
			currentCountry.modified = true;
			
			view.altnameList.selectedIndex = -1;
			if(currentCountry.modifiedProps.indexOf("altnames") == -1)
				currentCountry.modifiedProps.push("altnames");
		}
		private function handleUploadProgress(event:ProgressEvent):void {
			var status:String = (event.target == uploader) ? "Uploading..." : "Downloading...";
			view.uploadView.updateStatus(event.bytesLoaded/event.bytesTotal,status);
		}
		private function handleUploadComplete(event:Event):void {
			var status:String = (event.target == uploader) ? "Upload Complete" : "Download Complete";
			view.uploadView.updateStatus(1,status);
		}
		private function handleCountryUpdated(event:EditorEvent):void {
			view.statusModule.updateStatus("Update Completed");
			fileToUpload = null;
			if(event.type == EditorEvent.COUNTRY_CREATED) {
				view.countryList.selectedItem = currentCountry;
				ArrayCollection(view.countryList.dataProvider).filterFunction = null;
				ArrayCollection(view.countryList.dataProvider).refresh(); 
			}
		}
		private function handleCountryDeleted(event:EditorEvent):void {
			view.statusModule.updateStatus("Update Completed");
			if(ArrayCollection(view.countryList.dataProvider).length == 0) {
				ArrayCollection(view.countryList.dataProvider).filterFunction = null;
			}
			ArrayCollection(view.countryList.dataProvider).refresh();
			view.countryList.selectedIndex = 0;
			currentCountry = view.countryList.selectedItem;
			view.country = currentCountry;
			view.saveBtn.enabled = true;
			view.currentState = "edit";
		}
		private function handleSave(event:MouseEvent):void {	
			if(view.currentState == "edit") {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_COUNTRY,fileToUpload,currentCountry,uploader));
			}
			else {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_COUNTRY,fileToUpload,currentCountry,uploader));
			}
		} 
		private function handleCancel(event:MouseEvent):void {
			view.currentState = "edit";
		}
		private function handleSelection(event:IndexChangeEvent):void {
			currentCountry = view.countryList.selectedItem;
			view.country = currentCountry;
			view.saveBtn.enabled = true;
			view.currentState = "edit";
			this.fileToUpload = null;
		}
		private function handleAdd(event:MouseEvent):void {
			view.currentState = "add";
			view.saveBtn.enabled = false;
			currentCountry = new Country();
			view.country = currentCountry;
		}
		private function handleDelete(event:MouseEvent):void {
			view.errorPanel.errorMessage = "Are you sure you want to delete this country?\nThis change cannot be undone";
		}
		private function handleNotification(event:Event):void {
			if(event.type == "okEvent")
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DELETE_COUNTRY,currentCountry));
		}
	}
}