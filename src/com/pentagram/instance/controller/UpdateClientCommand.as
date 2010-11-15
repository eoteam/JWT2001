package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.services.interfaces.IInstanceService;
	
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateClientCommand extends Command
	{
		[Inject]
		public var model:InstanceModel;
		
		[Inject]
		public var service:IInstanceService;
		
		[Inject]
		public var event:EditorEvent;
		
		private var counter:int;
		private var total:int;
		override public function execute():void {
			counter = total = 0;
			if(model.client.modified) {
				service.saveClientInfo();
				service.addHandlers(handleClientSaved);
				//appService.addProperties("client",client);
				total++;
			}
			var country:Country
			for each(country in model.client.newCountries.source) {
				service.addClientCountry(country);
				service.addHandlers(handleAddCountry);
				//appService.addProperties("client",client);
				service.addProperties("country",country);
				total++;
			}
			for each(country in model.client.deletedCountries.source) {
				service.removeClientCountry(country);
				service.addHandlers(handleRemoveCountry);
				//appService.addProperties("client",client);
				service.addProperties("country",country);	
				total++;
			}	
		}
		
		private function handleClientSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				model.client.modifiedProps = [];
				counter++;
				model.client.modified = false;
				checkCount();
				//view.statusModule.updateStatus("Client Info Saved");
			}
		}
		private function handleAddCountry(event:ResultEvent):void {
			var country:Country = event.token.client as Country;
			var result:StatusResult = event.token.results as StatusResult;
			if(result.success) {
				model.client.newCountries.removeItem(country);
				counter++;
				checkCount();
			}
		}
		private function handleRemoveCountry(event:ResultEvent):void {
			var country:Country = event.token.client as Country;
			var result:StatusResult = event.token.results as StatusResult;
			if(result.success) {
				model.client.deletedCountries.removeItem(country);
				model.client.countries.removeItem(country);
				counter++;
				checkCount();
			}
		}	

		private function checkCount():void {
			if(counter == total) {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CLIENT_DATA_UPDATED));
			}
		}
	}
}