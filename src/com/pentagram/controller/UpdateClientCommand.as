package com.pentagram.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.model.vo.Client;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IClientService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateClientCommand extends Command
	{

		
		[Inject]
		public var service:IClientService;
		
		[Inject]
		public var event:EditorEvent;
		
		override public function execute():void {
			var client:Client = this.event.args[0] as Client;
			if(client.modified) {
				service.saveClientInfo(client);
				service.addHandlers(handleClientSaved);
			}
		}
		
		private function handleClientSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				var client:Client = this.event.args[0] as Client;
				client.modifiedProps = [];
				client.modified = false;
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CLIENT_DATA_UPDATED));
			}
		}
	}
}