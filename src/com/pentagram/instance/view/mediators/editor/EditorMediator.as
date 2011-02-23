package com.pentagram.instance.view.mediators.editor
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.editor.EditorMainView;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.MimeType;
	import com.pentagram.services.interfaces.IClientService;
	import com.pentagram.utils.CSVUtils;
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	import org.hamcrest.mxml.collection.Array;
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.IndexChangeEvent;
	import spark.validators.NumberValidator;
	
	public class EditorMediator extends Mediator
	{
		[Inject]
		public var  view:EditorMainView;
		
		[Inject]
		public var model:InstanceModel;

		[Inject]
		public var service:IClientService;
		
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;   
		
		
		//private var currentFiles:Array
		private var currentFile:File;
		private var currentRows:Array;
		private var totalSets:int;
		private var counter:int;
		public override function onRegister():void {	
		
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DATA_UPDATED,handleClientDataUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_UPDATED,handleClientDataUpdated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_CREATED,handleDatasetCreated,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.DATASET_DELETED,handleDatasetDeleted,EditorEvent);
			eventMap.mapListener(view,'datasetState',handleDatasetState,Event,false,0,true);

			eventMap.mapListener(appEventDispatcher,EditorEvent.START_IMPORT,handleStartImport,EditorEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.RESUME_IMPORT,handleResumeImport,EditorEvent);
			
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSaveChanges,false,0,true);
			view.cancelBtn.addEventListener(MouseEvent.CLICK,handleCancelChange,false,0,true); 
			
			view.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER,onDragIn,false,0,true);
			view.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDragDrop,false,0,true);
			view.dataSetList.addEventListener(IndexChangeEvent.CHANGE,handleDatasetChange,false,0,true);
			//view.dataSetList.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDragDrop,false,0,true);
			view.dataSetList.dataProvider = new ArrayCollection(model.client.datasets.source);
			
			view.deleteListBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
		}	
		private function handleSaveChanges(event:MouseEvent):void {
			if(view.currentState == "overview") {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_CLIENT_DATA,true));
			}
			else if(view.currentState == "dataset") {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_DATASET));
			}
		}
		private function handleCancelChange(event:MouseEvent):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CANCEL));
		}
		private function handleDelete(event:MouseEvent):void {
			var eventLoad:EditorEvent = new EditorEvent(EditorEvent.DELETE_DATASET,view.dataSetList.selectedItem);
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.NOTIFY,"Are you sure you want to delete this dataset?\nThis change cannot be undone",eventLoad));
			//eventDispatcher.dispatchEvent();
		}
		private function handleDatasetState(event:Event):void {
			view.deleteBtn.addEventListener(MouseEvent.CLICK,handleDelete,false,0,true);
		}
		private function handleClientDataUpdated(event:EditorEvent):void {
			view.statusModule.updateStatus("Client Data Updated");
		}
		private function handleClientLoaded(event:VisualizerEvent):void {
			view.dataSetList.dataProvider = new ArrayCollection(model.client.datasets.source);
			if(model.client.datasets.length > 0 ) {
				view.dataSetList.selectedIndex = 0;
				if(view.currentState == view.datasetState.name) {
					view.datasetEditor.dataset = model.client.datasets.getItemAt(0) as Dataset;
				}
			}
			else if(view.currentState == view.datasetState.name) {
				view.datasetEditor.dataset = null;
			}
		}
		private function handleDatasetCreated(event:EditorEvent):void {
			var dataset:Dataset = event.args[0] as Dataset;
			ArrayCollection(view.dataSetList.dataProvider).refresh();
			view.currentState = view.datasetState.name;
			view.dataSetList.selectedItem = dataset;
			model.selectedSet = view.dataSetList.selectedItem as Dataset;
			view.statusModule.updateStatus("Data Set Created");
			
			if(view.datasetEditor) {
				view.datasetEditor.dataset = dataset;
				view.datasetEditor.generateDataset();
			}
			counter++;
			if(counter == totalSets) //in casenew countries are added
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_CLIENT_DATA,false));
			
		}
		private function handleDatasetDeleted(event:EditorEvent):void {
			view.statusModule.updateStatus("Data Set Deleted");
			ArrayCollection(view.dataSetList.dataProvider).refresh();
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
				processFile(files[0] as File);
			}
		}
		private function handleStartImport(event:EditorEvent):void {
			var file:File = File.desktopDirectory; 
			file.addEventListener(Event.SELECT, onFileLoad); 
			file.browse([new FileFilter("Spreadsheet", "*.csv")]);
		}
		private function onFileLoad(event:Event):void {
			processFile(event.target as File);
		}
		private function processFile(file:File):void {
			currentFile = file
			
			var fs:FileStream = new FileStream();
			fs.open(currentFile, FileMode.READ);
			var csvContent:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			currentRows = CSVUtils.CsvToArray(csvContent);
			var header:Array = currentRows[0];
			
			if(header.length > 2) 
				this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.START_IMPORT));
			else	
				readFile(currentFile,currentRows,0);
		}
		private function handleResumeImport(event:EditorEvent):void {
			readFile(currentFile,currentRows,event.args[0] =="okEvent"?1:0);
		}
		private function deleteDatasets(event:Event):void {
			
		}
		private function readFile(file:File,rows:Array,time:int):void {
			totalSets = 1;counter = 0;
			var fileName:String = file.name.replace(/.csv/gi,'');
			var header:Array = rows[0];
			if(rows.length > 2) {
				header = rows[0];
				if(header[0].toString().toLowerCase() != "country")
					showError("First column is not named 'Country'");
				
				if(header.length > 2) {
					if(time == 1)
						parseDataset(fileName,rows);
					
					else {
						var i:int; var j:int;var set:Array;var newRow:Array; 
						var datasets:Array = [];
						for(i=1;i<header.length;i++) {
							var newHeader:Array = [];
							newHeader[0] = "Country";
							newHeader[1] = header[i];
							set = [];
							set[0] = newHeader;
							datasets.push(set);
						} 
						for(i=1;i<rows.length;i++) {
							var row:Array = rows[i];
							var limit:int = header.length > row.length?row.length:header.length;
							for (j=0;j<limit-1;j++) {
								set = datasets[j] as Array;
								newRow = [];
								newRow[0] = row[0];
								newRow[1] = row[j+1];
								set.push(newRow);
							}
							for(j=limit;j<header.length-1;j++) {
								set = datasets[j] as Array;
								newRow = [];
								newRow[0] = row[0];
								newRow[1] = '';
								set.push(newRow);
							}
						}
						trace("rotation finished");
						totalSets = datasets.length;
						for (i=0;i<datasets.length;i++) {
							set = datasets[i];
							parseDataset(header[i+1],set);
						}
					}
				}
				else if(header.length == 2) 
					parseDataset(fileName,rows);
			}
			else 
				showError("Spreadsheet doesnt have enough rows");
		}
		private function parseDataset(fileName:String,rows:Array):void {
			var i:int;
			var j:int;
			var header:Array;
			var isNumeric:int = 1;
			var badRows:Array = [];
			var countryFound:Boolean = false;
			var countryName:String;
			var cell:String;
			var dataRow:DataRow;
			
			for each(var ds:Dataset in model.client.datasets.source) {
				if(ds.name == fileName) {
					showError("This name is already taken. Please rename your file");
					return;
				}
			}
			var dataset:Dataset = new Dataset();
			dataset.type = 1; //start with number
			dataset.name = fileName; 
			
			header = rows[0];
		
			if(header.length > 2) {
				dataset.years = [];
				for(i=1;i<header.length;i++) {
					//						if(isNaN(parseInt(header[i]))) {
					//							showError("Header doesnt contain proper years");
					//							return;
					//			
					var h:String = header[i].toString().split(' ').join('').split('-').join('_');
					header[i] = h;
					dataset.years.push(h); 
				}
				dataset.years.sort();
				dataset.time = 1;
			}
			else
				dataset.time = 0;

			
			for (i=1;i<rows.length;i++) {
				var row:Array = rows[i];
				//if(row.length != header.length) {
					//showError("This row's columns dont match the header's columns");
					//badRows.push(row);
				//}
				//else {
					countryName = StringUtil.trim(row[0]);
					if(model.countryNames[countryName.toLowerCase()] == null) {
						//showError("This row's country is not found");
						badRows.push(row);
					}
					else {
						dataRow = new DataRow();
						dataRow.name = countryName;
						dataRow.dataset = dataset;
						dataRow.country = model.countryNames[countryName.toLowerCase()] as Country;
						if(model.client.countries.getItemIndex(dataRow.country) == -1) //in the system, add to client
							eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ADD_COUNTRY_FROM_IMPORT,dataRow.country));
						if(dataset.time == 0) 
							parseCell(row[1],dataset,dataRow,"value");
						else {	
							var limit:int = header.length > row.length?row.length:header.length;
							for(j=1;j<limit;j++) 
								parseCell(row[j],dataset,dataRow,header[j]);  
						}
						dataset.rows.addItem(dataRow);
					}
				//}
			}
			var err:String = '';
			for each(row in badRows) {
				if(row.lenght>0)
					err += row[0].toString() + "\n";
			}
			if(err != '')
				showError(err);
			
			dataset.options = '';	
			if(dataset.type == 1)
				updateMinMax(dataset);
			else {
				for each(var cat:Category in dataset.optionsArray) 
					dataset.options += cat.name+',';
				dataset.options = dataset.options.substr(0,dataset.options.length-1);	
			}
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_DATASET,dataset));
		}
		
		private function parseCell(cell:String,dataset:Dataset,row:DataRow,field:String):void {
			var copy:String = cell;
			if(copy == '' || copy.toLowerCase() == 'n/a' || copy.toLowerCase() == 'na' || copy.toLowerCase() == '-') {
				row[field] = 'NULL';
			}
			else {
				copy = cell.split(',').join('').toLowerCase();
				if(isNaN(parseFloat(copy)) && copy.length > 1) { ///this is def a word, whole set is turned into a quantitative set
					dataset.type = 0;
					row[field] = cell;
					var f:Boolean = false;
					for each(var cat:Category in dataset.optionsArray) {
						if(cat.name.toLowerCase() == cell.toLowerCase()) {
							f = true;
							break;
						}
					}
					if(!f) {
						var category:Category = new Category();
						category.name = cell;
						dataset.optionsArray.push(category);
					}
				}
				else {
					row[field] = parseFloat(copy);
				}
			}
			row.modifiedProps.push(field);
		}
		private function updateMinMax(dataset:Dataset):void {
			for each(var row:DataRow in dataset.rows) {
				if(dataset.time == 1) {
					for (var i:int = 0;i< dataset.years.length;i++) {
						if(row[dataset.years[i]] < dataset.min) {
							setPropChanged(dataset,"min",row[dataset.years[i]]);
						}
						if(row[dataset.years[i]] > dataset.max) {
							setPropChanged(dataset,"max",row[dataset.years[i]]);
						}			
					}
				}
				else {
					if(row.value < dataset.min) {
						setPropChanged(dataset,"min",row.value);
					}
					else if(row.value > dataset.max) {
						setPropChanged(dataset,"max",row.value);
					}
				}
			}
		}
		private function setPropChanged(dataset:Dataset,prop:String,value:Number):void {
			dataset[prop] = value;
			dataset.modified = true;
			if(dataset.modifiedProps.indexOf(prop) == -1)
				dataset.modifiedProps.push(prop);
		}
		private function showError(msg:String):void {
			view.statusModule.updateStatus(msg);
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.ERROR,msg));
		}
	}
}
/*// Choose the line ending to split the lines based on which one yields more than one line
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

var fields:Array = lines[0].split(',');

if(fields.length > 2) { //time based

for (var j:int=1;j<fields.length;j++) {
var year:int = Number(fields[j]);
if(year == 0)  { //fail
view.statusModule.updateStatus("Header Column doesnt contain proper years");
eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.IMPORT_FAILED,"Header Column doesnt contain proper years"));
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
view.statusModule.updateStatus("This row has more values than the set");
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
view.statusModule.updateStatus("Country Not Found");
eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.IMPORT_FAILED,"Country Not Found"));
//return;
}
}
}
dataset.type = isNumeric;
eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_DATASET,dataset));				
}
*/