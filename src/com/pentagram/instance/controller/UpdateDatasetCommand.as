	package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Category;
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
				//repopulate color info for options for quant datasets
				if(model.selectedSet.type == 0) {
					for(var i:int=0; i < model.selectedSet.optionsArray.length; i++) {		
						var c:Category = model.selectedSet.optionsArray[i];
						c.color = model.colors[i];
						model.selectedSet.colorArray[c.name] = c.color;
					}
				}
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_UPDATED));
				
			}
		}
		private function updateMinMax():void {
			for each(var row:DataRow in model.selectedSet.rows) {
				if(model.selectedSet.time == 1) {
					for (var i:int = 0;i< model.selectedSet.years.length;i++) {
						if(row[model.selectedSet.years[i]] < model.selectedSet.min) {
							setPropChanged("min",row[model.selectedSet.years[i]]);
						}
						if(row[model.selectedSet.years[i]] > model.selectedSet.max) {
							setPropChanged("max",row[model.selectedSet.years[i]]);
						}			
					}
				}
				else {
					if(row.value < model.selectedSet.min) {
						setPropChanged("min",row.value);
					}
					else if(row.value > model.selectedSet.max) {
						setPropChanged("min",row.value);
					}
				}
			}
			model.selectedSet.maxCopy = model.selectedSet.max;
			model.selectedSet.minCopy = model.selectedSet.min;
		}
		private function setPropChanged(prop:String,value:Number):void {
			model.selectedSet[prop] = value;
			model.selectedSet.modified = true;
			if(model.selectedSet.modifiedProps.indexOf(prop) == -1)
				model.selectedSet.modifiedProps.push(prop);
		}
	}
}