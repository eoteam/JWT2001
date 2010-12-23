package com.pentagram.instance.view.mediators.editor
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.editor.EditorMainView;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.OpenWindowsProxy;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.MimeType;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.services.interfaces.IInstanceService;
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragManager;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.IndexChangeEvent;
	
	public class EditorMediator extends Mediator
	{
		[Inject]
		public var  view:EditorMainView;
		
		[Inject]
		public var model:InstanceModel;

		[Inject]
		public var service:IInstanceService;
		
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;   
		
		
		public override function onRegister():void {	
		
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DATA_UPDATED,handleClientDataUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_UPDATED,handleClientDataUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_CREATED,handleDatasetCreated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_DELETED,handleDatasetDeleted,EditorEvent);
			eventMap.mapListener(view,'datasetState',handleDatasetState,Event,false,0,true);

			eventMap.mapListener(appEventDispatcher,EditorEvent.START_IMPORT,handleStartImport,EditorEvent);
			
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSaveChanges,false,0,true);
			view.cancelBtn.addEventListener(MouseEvent.CLICK,handleCancelChange,false,0,true); 
			
			view.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER,onDragIn,false,0,true);
			view.addEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE,onDragComplete,false,0,true);
			view.dataSetList.addEventListener(IndexChangeEvent.CHANGE,handleDatasetChange,false,0,true);
			view.dataSetList.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,dataSetList_nativeDragDropHandler,false,0,true);
			
			view.deleteListBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
		}	
		private function handleSaveChanges(event:MouseEvent):void {
			if(view.currentState == "overview") {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_CLIENT_DATA,view.client));
			}
			else if(view.currentState == "dataset") {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_DATASET));
			}
		}
		private function handleCancelChange(event:MouseEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CANCEL));
		}
		private function handleDelete(event:MouseEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DELETE_DATASET,view.dataSetList.selectedItem));
		}
		private function handleDatasetState(event:Event):void {
			view.deleteBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
		}
		private function handleClientDataUpdated(event:EditorEvent):void {
			view.statusModule.updateStatus("Client Data Updated");
		}
		private function handleDatasetCreated(event:EditorEvent):void {
			var dataset:Dataset = event.args[0] as Dataset;
			view.currentState = view.datasetState.name;
			view.dataSetList.selectedItem = dataset;
			model.selectedSet = view.dataSetList.selectedItem as Dataset;
			view.statusModule.updateStatus("Data Set Created");
			
			if(view.datasetEditor) {
				view.datasetEditor.dataset = dataset;
				view.datasetEditor.generateDataset();
			}
		}
		private function handleDatasetDeleted(event:EditorEvent):void {
			view.statusModule.updateStatus("Data Set Deleted");
			if(model.client.datasets.length == 0) {
				if(view.datasetEditor)
					view.datasetEditor.dataset = null;
				view.currentState = view.overviewState.name;
			}
			else {
				view.dataSetList.selectedIndex = 0;
				if(view.datasetEditor) {
					view.datasetEditor.dataset = model.client.datasets.getItemAt(0) as Dataset;
					view.datasetEditor.generateDataset();
				}
			}
		}
		private function handleDatasetChange(event:IndexChangeEvent):void {
			model.selectedSet = view.dataSetList.selectedItem as Dataset;
			if(view.currentState == view.datasetState.name && view.datasetEditor)
				view.datasetEditor.dataset = view.dataSetList.selectedItem as Dataset;
				view.datasetEditor.generateDataset();
		}
		private function onDragIn(event:NativeDragEvent):void {
			if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {	
				var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				if(MimeType.getMimetype(File(files[0]).extension) == MimeType.FILE && File(files[0]).extension == "csv") {
					NativeDragManager.acceptDragDrop(view.dataSetList); 
					if(view.currentState == "dataset") {

					}
				}
				else if(MimeType.getMimetype(File(files[0]).extension) == MimeType.IMAGE) {
					if(view.currentState == "overview")
						NativeDragManager.acceptDragDrop(view.overviewEditor.logoHolder);
				}
			}
		}
		private function onDragDrop(event:NativeDragEvent):void {
			if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			}
		}
		private function onDragComplete(event:NativeDragEvent):void {

		}
		private function handleStartImport(event:EditorEvent):void {
			var file:File = File.desktopDirectory; 
			file.addEventListener(Event.SELECT, onFileLoad); 
			file.browse([new FileFilter("Spreadsheet", "*.csv")]);
		}
		private function onFileLoad(event:Event):void {
			readFile(event.target as File);
		}
		private function dataSetList_nativeDragDropHandler(event:NativeDragEvent):void {
			if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				readFile(files[0] as File);
			}
		}
		private function deleteDatasets(event:Event):void {
			
		}
		private function readFile(file:File):void {
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var csvFile:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			
			// Choose the line ending to split the lines based on which one yields more than one line
			var endings:Array = [File.lineEnding, "\n", "\r"];
			var i:uint = 1;
			var lines:Array = csvFile.split(endings[0]);
			while(lines.length == 1 && i < endings.length) {
				lines = csvFile.split(endings[i++]);
			}
			for (i=0;i<lines.length;i++) {
				lines[i] = lines[i].toString().replace(/\r/gi,'');
			}
			//check line 0
			var dataset:Dataset = new Dataset();
			dataset.name =  file.name.replace(/.csv/gi,'');
			var fields:Array = lines[0].split(',');

			if(fields.length > 2) { //time based
				
				for (var j:int=1;j<fields.length;j++) {
					var year:int = Number(fields[j]);
					if(year == 0)  { //fail
						eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.IMPORT_FAILED,"Header Column doesnt container proper years"));
						return;
					}
				}
				dataset.time = 1;
				dataset.years = [Number(fields[1]),Number(fields[fields.length-1])];
				dataset.range = fields[1]+','+fields[fields.length-1];
			}
			else {
				dataset.time = 0;
			}
			for(i=1;i<lines.length;i++) {
				if(lines[i] != '') {
					var countryName:String
					var arr:Array = lines[i].toString().split('",');
					var offset:uint = 1;
					
					if(arr.length == 1) {
						arr = lines[i].toString().split(',');
						offset = 0;
					}
					
					countryName = arr[0].toString().substr(offset,arr[0].toString().length);
					var isNumeric:uint = 1;
					var countryFound:Boolean = false;
					for each(var country:Country in model.countries.source) {
						if(countryName == country.name) {
							var row:DataRow = new DataRow();
							row.name = countryName;
							row.dataset = dataset;
							row.country = country;
						
							//values are now after ",	
							var values:Array;
							var cleanValue:String;
							if(offset == 1)
								values = arr[1].toString().split(',');
							else
								values = arr.slice(1,arr.length);
							
							if(dataset.time == 1) {
								if(values.length <= fields.length-1) {
									for(j=1;j<values.length;j++) {
										cleanValue = values[j-1].toString().split('"').join('');
										row.modifiedProps.push(fields[j].toString());
										
										if(Number(cleanValue) > 0 || cleanValue == "0") {
											isNumeric = 1;
											row[fields[j].toString()] = Number(cleanValue);
										}
										else {
											isNumeric = 0;
											row[fields[j].toString()] = cleanValue;
										}
									}
									//if the row is shorter than the number of columns
									for(j=values.length;j<fields.length;j++) {
										row[fields[j].toString()] = isNumeric == 1 ? 0:'';
									}
								}
								else {
									eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.IMPORT_FAILED,"This row has more values than the set"));
									return;
								}
							}
							
							
							else {
								cleanValue = arr[1].toString().split('"').join('');	
								row.modifiedProps.push('value');
								if(Number(cleanValue) > 0 || cleanValue == "0") {
									isNumeric = 1;
									row.value = Number(cleanValue);
									
								}
								else {
									isNumeric = 0;
									row.value = cleanValue;
								}								
							}
							dataset.rows.addItem(row);
							countryFound = true;
							break;	
						}
					}
					if(!countryFound) {
						eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.IMPORT_FAILED,"Country Not Found"));
						//return;
					}
				}
			}
			dataset.type = isNumeric;
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_DATASET,dataset));				
		}		
	}
}