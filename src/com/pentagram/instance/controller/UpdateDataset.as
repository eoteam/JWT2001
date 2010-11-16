	package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.services.interfaces.IDatasetService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateDataset extends Command
	{
		[Inject]
		public var model:InstanceModel;
		
		[Inject]
		public var service:IDatasetService;
		
		private var counter:int;
		private var total:int;
		
		override public function execute():void {
			if(model.selectedSet) {
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
		private function checkCount():void {
			if(counter == total) {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.DATASET_UPDATED)); 
			}
		}		
	}
}