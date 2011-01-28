package com.pentagram.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.BaseVO;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class DeleteCountryCommand extends Command
	{
		[Inject]
		public var service:IAppService;
		
		[Inject]
		public var event:EditorEvent;
		
		[Inject]
		public var model:AppModel;
		
		override public  function execute():void {
			 service.deleteVO(event.args[0] as BaseVO);
			 service.addHandlers(handleDelete);
		}
		private function handleDelete(evt:ResultEvent):void {
			var result:StatusResult = evt.token.results as StatusResult;	
			var country:Country = event.args[0] as Country;
			if(result.success) {
				model.countries.removeItem(country);
				//update all datasets
				for each(var client:Client in model.clients.source) {
					if(client.countries.getItemIndex(country) != -1) {
						client.countries.removeItem(country);
						for each(var dataset:Dataset in client.datasets.source) {
							for each(var row:DataRow in dataset.rows) {
								if(row.country == country) {
									dataset.rows.removeItemAt(dataset.rows.getItemIndex(row));
									break;
								}
							}
						}
					}
				}
				
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.COUNTRY_DELETED,event.args[0]))
			}
		}
	}
}