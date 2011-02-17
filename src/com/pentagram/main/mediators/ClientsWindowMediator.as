package com.pentagram.main.mediators
{
	import com.pentagram.controller.Constants;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.view.editor.RegionDrawer;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.main.windows.ClientsWindow;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Region;
	import com.pentagram.utils.Downloader;
	import com.pentagram.utils.Uploader;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.IndexChangeEvent;

	public class ClientsWindowMediator extends Mediator
	{
		[Inject]
		public var view:ClientsWindow;
		
		[Inject]
		public var model:AppModel;
		
		private var uploader:Uploader;
		private var downloader:Downloader;
		
		private var currentClient:Client;
		private var fileToUpload:File;
		
		override public function onRegister():void
		{
			view.clientList.dataProvider = new ArrayCollection(model.clients.source);
			view.clientList.addEventListener(IndexChangeEvent.CHANGE,handleSelection,false,0,true);
			view.clientList.selectedIndex = 0;
			handleSelection();
			
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSaveChanges,false,0,true);
			view.deleteBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
			view.deleteListBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
			view.addButton.addEventListener(MouseEvent.CLICK,handleAdd,false,0,true);
			view.cancelBtn.addEventListener(MouseEvent.CLICK,handleCancel,false,0,true);
			view.changeImageBtn.addEventListener(MouseEvent.CLICK,handleChangeImage,false,0,true);
			view.downloadBtn.addEventListener(MouseEvent.CLICK,handleDownload,false,0,true);
			
			this.addViewListener(ViewEvent.CLIENT_PROP_CHANGED,handlePropChange,ViewEvent);
			
			uploader = new Uploader(Constants.UPLOAD_URL);
			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			uploader.addEventListener(ProgressEvent.PROGRESS,handleUploadProgress);
			
			downloader = new Downloader(Constants.FILES_URL);
			downloader.addEventListener(Event.COMPLETE,handleUploadComplete);
			downloader.addEventListener(ProgressEvent.PROGRESS,handleUploadProgress);
			
			eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event,false,0,true);
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DATA_UPDATED,handleClientUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_CREATED,handleClientUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DELETED,handleClientDeleted,EditorEvent);
			
			view.countryInput.dataProvider = model.countries.source;
			view.countryInput.addEventListener(CustomEvent.SELECT,countryList_selectHandler,false,0,true);
			
		}
		private function handleWindowClose(event:Event):void {
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.WINDOW_CLOSED, view.id));
			mediatorMap.removeMediator(this);
		}
		private function handleChangeImage(event:MouseEvent):void {
			fileToUpload = File.desktopDirectory; 
			fileToUpload.addEventListener(Event.SELECT, onFileLoad); 
			fileToUpload.browse([new FileFilter("Images", ".gif;*.jpeg;*.jpg;*.png")]); 
		}
		private function handleDownload(event:MouseEvent):void {
			downloader.download(currentClient.thumb);
		}
		private function onFileLoad(event:Event):void {
			view.logo.source = "file:///" + fileToUpload.nativePath;
		}
		
		private function handlePropChange(event:ViewEvent):void {
			var prop:String = event.args[0] as String;
			var value:String = event.args[1] as String;
			var client:Client = event.args[2] as Client;
			if(client.modifiedProps.indexOf(prop) == -1) {
				client.modifiedProps.push(prop);
			}
			client[prop] = value;
			client.modified = true;
		}
		private function handleUploadProgress(event:ProgressEvent):void {
			var status:String = (event.target == uploader) ? "Uploading..." : "Download...";
			view.uploadView.updateStatus(event.bytesLoaded/event.bytesTotal,status);
		}
		private function handleUploadComplete(event:Event):void {
			var status:String = (event.target == uploader) ? "Upload Complete" : "Download Complete";
			view.uploadView.updateStatus(1,status);
		}
		private function handleCountryUpdated(event:EditorEvent):void {
			view.statusModule.updateStatus("Update Completed");
			fileToUpload = null;
			if(event.type == EditorEvent.CLIENT_CREATED) {
				view.clientList.selectedItem = currentClient;
				ArrayCollection(view.clientList.dataProvider).filterFunction = null;
				ArrayCollection(view.clientList.dataProvider).refresh(); 
			}
		}
		private function handleSaveChanges(event:MouseEvent):void {
			if(view.currentState == "edit")
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_CLIENT_DATA,fileToUpload,currentClient,uploader));
			else
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_CLIENT,fileToUpload,currentClient,uploader));  
		}
	
		private function handleClientUpdated(event:EditorEvent):void {
			view.statusModule.updateStatus("Update Completed");
			fileToUpload = null;
			if(event.type == EditorEvent.CLIENT_CREATED) {
				
				view.clientList.selectedItem = currentClient;
				ArrayCollection(view.clientList.dataProvider).filterFunction = null;
				ArrayCollection(view.clientList.dataProvider).refresh(); 
			}
			view.currentState = "edit";
		}
		private function handleClientDeleted(event:EditorEvent):void {
			view.statusModule.updateStatus("Update Completed");
			if(ArrayCollection(view.clientList.dataProvider).length == 0) {
				ArrayCollection(view.clientList.dataProvider).filterFunction = null;
			}
			ArrayCollection(view.clientList.dataProvider).refresh();
			view.clientList.selectedIndex = 0;
			currentClient = view.clientList.selectedItem;
			view.client = currentClient;
			view.currentState = "edit";
		}
		private function handleSelection(event:IndexChangeEvent=null):void {
			currentClient = view.clientList.selectedItem;
			view.client = currentClient;
			view.saveBtn.enabled = true;
			view.currentState = isNaN(currentClient.id) ? "add":"edit";
			this.fileToUpload = null;
			
			view.regionHolder.removeAllElements();
			for each(var region:Region in currentClient.regions.source) {
				if(region.countries.length > 0) {
					var drawer:RegionDrawer = new RegionDrawer();
					drawer.region = region;
					drawer.addEventListener(IndexChangeEvent.CHANGE,handleCountryListSelection,false,0,true);
					view.regionHolder.addElement(drawer);
				}
			}
		}
		protected function countryList_selectHandler(event:CustomEvent):void {
			if(currentClient.countries.getItemIndex(event.data) == -1) {
				currentClient.countries.addItem(event.data);
				currentClient.newCountries.addItem(event.data);
				for each(var region:Region in currentClient.regions.source) {
					if(region.id == event.data.region.id) {
						region.countries.addItem(event.data);
						if(region.countries.length == 1) {
							var drawer:RegionDrawer = new RegionDrawer();
							drawer.region = region;
							drawer.addEventListener(IndexChangeEvent.CHANGE,handleCountryListSelection,false,0,true);
							view.regionHolder.addElement(drawer);
						}
						break;
					}
				}
			}
		}
		private function handleCountryListSelection(event:IndexChangeEvent):void {
			
		}
		private function handleAdd(event:MouseEvent):void {
			view.currentState = "add";	
			currentClient = new Client();
			currentClient.name = "New Client";
			view.client = currentClient;
			model.clients.addItem(currentClient);
			ArrayCollection(view.clientList.dataProvider).refresh();
			view.clientList.selectedIndex = view.clientList.dataProvider.length-1;
		}
		private function handleCancel(event:MouseEvent):void {
			model.clients.removeItem(currentClient);
			ArrayCollection(view.clientList.dataProvider).refresh();
			view.clientList.selectedIndex = 0;
			currentClient = view.clientList.selectedItem;
			view.client = currentClient;
			view.currentState = "edit";
		}
		private function handleDelete(event:MouseEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DELETE_CLIENT,currentClient));
		}
	}
}