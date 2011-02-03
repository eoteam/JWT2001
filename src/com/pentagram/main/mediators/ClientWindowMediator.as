package com.pentagram.main.mediators
{
	import com.pentagram.controller.Constants;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.main.windows.ClientListWindow;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.utils.Uploader;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.IndexChangeEvent;

	public class ClientWindowMediator extends Mediator
	{
		[Inject]
		public var view:ClientListWindow;
		
		[Inject]
		public var model:AppModel;
		
		private var uploader:Uploader;
		private var currentClient:Client;
		private var fileToUpload:File;
		
		override public function onRegister():void
		{
			view.clientList.dataProvider = new ArrayCollection(model.clients.source);
			view.clientList.addEventListener(IndexChangeEvent.CHANGE,handleSelection,false,0,true);
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSaveChanges,false,0,true);
			view.addButton.addEventListener(MouseEvent.CLICK,handleAdd,false,0,true);
			view.changeImageBtn.addEventListener(MouseEvent.CLICK,handleChangeImage,false,0,true);
			
			this.addViewListener(ViewEvent.CLIENT_PROP_CHANGED,handlePropChange,ViewEvent);
			
			uploader = new Uploader(Constants.UPLOAD_URL);
			uploader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,handleUploadComplete);
			uploader.addEventListener(ProgressEvent.PROGRESS,handleUploadProgress);
			
			eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event,false,0,true);
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DATA_UPDATED,handleClientUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_CREATED,handleClientUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DELETED,handleClientDeleted,EditorEvent);

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
			view.uploadView.updateStatus(event.bytesLoaded/event.bytesTotal);
		}
		private function handleUploadComplete(event:DataEvent):void {
			view.uploadView.updateStatus(1);
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
			view.saveBtn.enabled = true;
			view.currentState = "edit";
		}
		private function handleSelection(event:IndexChangeEvent):void {
			currentClient = view.clientList.selectedItem;
			view.client = currentClient;
			view.saveBtn.enabled = true;
			view.currentState = "edit";
		}
		private function handleAdd(event:MouseEvent):void {
			view.currentState = "add";
			//view.saveBtn.enabled = false;
			currentClient = new Client();
			view.client = currentClient;
		}
	}
}