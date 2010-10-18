package com.pentagram.controller
{
	import com.pentagram.event.EditorEvent;
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IAppService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateClientCommand extends Command
	{
		[Inject]
		public var appModel:AppModel;
		
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var event:EditorEvent;
		
		private var counter:int;
		private var total:int;
		override public function execute():void {
			counter = total = 0;
			var client:Client = event.args[0] as Client;
			if(client.modified) {
				appService.saveClientInfo(event.args[0] as Client);
				appService.addHandlers(handleClientSaved);
				appService.addProperties("client",client);
				total++;
			}
			var country:Country
			for each(country in client.newCountries) {
				appService.addClientCountry(client,country);
				appService.addHandlers(handleAddCountry);
				appService.addProperties("client",client);
				appService.addProperties("country",country);
				total++;
			}
			for each(country in client.deletedCountries) {
				appService.removeClientCountry(client,country);
				appService.addHandlers(handleRemoveCountry);
				appService.addProperties("client",client);
				appService.addProperties("country",country);	
				total++;
			}
		}
		
		private function handleClientSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			var client:Client = event.token.client as Client;
			if(result.success) {
				client.modifiedProps = [];
				counter++;
				client.modified = true;
				checkCount();
				//view.statusModule.updateStatus("Client Info Saved");
			}
		}
		private function handleAddCountry(event:ResultEvent):void {
			var client:Client = event.token.client as Client;
			var country:Country = event.token.client as Country;
			var result:StatusResult = event.token.results as StatusResult;
			if(result.success) {
				client.newCountries.splice(client.newCountries.indexOf(country),1);
				counter++;
				checkCount();
			}
		}
		private function handleRemoveCountry(event:ResultEvent):void {
			var client:Client = event.token.client as Client;
			var country:Country = event.token.client as Country;
			var result:StatusResult = event.token.results as StatusResult;
			if(result.success) {
				client.deletedCountries.splice(client.deletedCountries.indexOf(country),1);
				client.countries.removeItem(country);
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