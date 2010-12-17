	package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.services.interfaces.IDatasetService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateDatasetCommand extends Command
	{
		[Inject]
		public var model:InstanceModel;
		
		[Inject]
		public var service:IDatasetService;
		
		private var counter:int;
		private var total:int;
		
		override public function execute():void {
			if(model.selectedSet) {
				//check max min
				if(model.selectedSet.type == 1) {
					updateMinMax();
				}
				if(model.selectedSet.modified) {
					service.updateDataset(model.selectedSet);
					service.addHandlers(handleDatasetUpdated);			
					total++;
				}
				
				for each(var row:DataRow in model.selectedSet.rows) {
					if(row.modified) {
						service.updateDataRow(row);
						service.addHandlers(handleRowUpdated);
						service.addProperties("row",row);
						total++;
					}
				}
			}			
		}
		private function handleRowUpdated(event:ResultEvent):void {
			var row:DataRow = event.token.row;
			row.modified = false;
			row.modifiedProps = [];
			counter++;	
			checkCount();
		}
		private function handleDatasetUpdated(event:ResultEvent):void {
			model.selectedSet.modified = false;
			model.selectedSet.modifiedProps = [];
			counter++;
			checkCount();			
		}
		
		private function checkCount():void {
			if(counter == total) {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_UPDATED)); 
			}
		}
		private function updateMinMax():void {
			var max:Number = model.selectedSet.max; 
			var min:Number = model.selectedSet.min;
			for each(var row:DataRow in model.selectedSet.rows) {
				if(model.selectedSet.time == 1) {
					for (var i:int=model.selectedSet.years[0];i<=model.selectedSet.years[1];i++) {
						if(row[i] < min) {
							setPropChanged("min",row[i]);
						}
						else if(row[i] > max) {
							setPropChanged("max",row[i]);
						}			
					}
				}
				else {
					if(row.value < min) {
						setPropChanged("min",row.value);
					}
					else if(row.value > max) {
						setPropChanged("min",row.value);
					}
				}
			}
		}
		private function setPropChanged(prop:String,value:Number):void {
			model.selectedSet[prop] = value;
			model.selectedSet.modified = true;
			if(model.selectedSet.modifiedProps.indexOf(prop) == -1)
				model.selectedSet.modifiedProps.push(prop);
		}
	}
}