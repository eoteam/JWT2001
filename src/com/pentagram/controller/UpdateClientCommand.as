package com.pentagram.controller
{
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
		public var event:VisualizerEvent;
		
		override public function execute():void {
			var client:Client = event.args[0] as Client;
			appService.saveClientInfo(event.args[0] as Client);
			appService.addHandlers(handleClientSaved);
			appService.addProperties("client",client);
			for each(var country:Country in client.newCountries) {
				appService.addClientCountry(client,country);
				appService.addHandlers(handleAddCountry);
				appService.addProperties("client",client);
				appService.addProperties("country",country);
			}
		}
		
		private function handleClientSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			var client:Client = event.token.client as Client;
			if(result.success) {
				client.modifiedProps = [];
				//view.statusModule.updateStatus("Client Info Saved");
			}
		}
		private function handleAddCountry(event:ResultEvent):void {
			var client:Client = event.token.client as Client;
			var country:Country = event.token.client as Country;
			client.newCountries.spl
		}
	}
}