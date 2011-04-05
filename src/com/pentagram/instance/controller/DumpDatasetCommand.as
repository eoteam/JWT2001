package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.interfaces.IDatasetService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class DumpDatasetCommand extends Command
	{		
		[Inject]
		public var service:IDatasetService;
		
		[Inject]
		public var event:EditorEvent;
		
		private var counter:int;
		private var total:int;
		private var dataset:Dataset 
		override public function execute():void {
			
			dataset = event.args[0] as Dataset;
			//check max min
			if(dataset.type == 1) {
				updateMinMax();
				dataset.minCopy = dataset.min;
				dataset.maxCopy = dataset.max;
			}
			if(dataset.modified) { 
				service.updateDataset(dataset);
				service.addHandlers(handleDatasetUpdated);			
				total++;
			}
			for each(var row:DataRow in dataset.rows) {
				service.updateDataRow(row);
				service.addHandlers(handleRowUpdated);
				service.addProperties("row",row);
				total++;
			}
			trace(dataset.name,total);			
		}
		private function handleRowUpdated(event:ResultEvent):void {
			var row:DataRow = event.token.row;
			row.modified = false;
			row.modifiedProps = [];
			counter++;	
			checkCount();
		}
		private function handleDatasetUpdated(event:ResultEvent):void {
			dataset.modified = false;
			dataset.modifiedProps = [];
			counter++;
			checkCount();			
		}
		
		private function checkCount():void {
			if(counter == total) {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_CREATED,dataset)); 
			}
		}
		private function updateMinMax():void {
			for each(var row:DataRow in dataset.rows) {
				if(dataset.time == 1) {
					for (var i:int = 0;i< dataset.years.length;i++) {
						if(row[dataset.years[i]] < dataset.min) {
							setPropChanged("min",row[i]);
						}
						if(row[dataset.years[i]] > dataset.max) {
							setPropChanged("max",row[dataset.years[i]]);
						}			
					}
				}
				else {
					if(row.value < dataset.min) {
						setPropChanged("min",row.value);
					}
					else if(row.value > dataset.max) {
						setPropChanged("min",row.value);
					}
				}
			}
		}
		private function setPropChanged(prop:String,value:Number):void {
			dataset[prop] = value;
			dataset.modified = true;
			if(dataset.modifiedProps.indexOf(prop) == -1)
				dataset.modifiedProps.push(prop);
		}
	}
}