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
		private var currentCountry:Country;
		private var fileToUpload:File;
		
		override public function onRegister():void {
			view.countryList.dataProvider = new ArrayCollection(model.countries.source);
			view.countryList.addEventListener(IndexChangeEvent.CHANGE,handleSelection,false,0,true);
			view.continentList.dataProvider = model.regions;
			view.addButton.addEventListener(MouseEvent.CLICK,handleAdd,false,0,true);
			view.deleteBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSave,false,0,true);
			view.cancelBtn.addEventListener(MouseEvent.CLICK,handleCancel,false,0,true);
			view.logoHolder.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDragDrop,false,0,true);
			view.changeImageBtn.addEventListener(MouseEvent.CLICK,handleChangeImage,false,0,true);
			
			this.addViewListener(ViewEvent.CLIENT_PROP_CHANGED,handlePropChange,ViewEvent);
			
			uploader = new Uploader(Constants.UPLOAD_URL);
			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			uploader.addEventListener(ProgressEvent.PROGRESS,handleUploadProgress);
			
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
		private function onFileLoad(event:Event):void {
			view.logo.source = "file:///" + fileToUpload.nativePath;
		}

		private function handleUploadProgress(event:ProgressEvent):void {
			view.uploadView.updateStatus(event.bytesLoaded/event.bytesTotal);
		}
		private function handleUploadComplete(event:DataEvent):void {
			view.uploadView.updateStatus(1);
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
		}
		private function handleAdd(event:MouseEvent):void {
			view.currentState = "add";
			view.saveBtn.enabled = false;
			currentCountry = new Country();
			view.country = currentCountry;
		}
		private function handleDelete(event:MouseEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DELETE_COUNTRY,currentCountry));
		}
	}
}