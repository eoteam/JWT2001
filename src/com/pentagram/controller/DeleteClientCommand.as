package com.pentagram.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.interfaces.IClientService;
	import com.pentagram.services.StatusResult;
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class DeleteClientCommand extends Command
	{
		[Inject]
		public var event:EditorEvent;
		
		[Inject]
		public var service:IClientService;
		
		[Inject]
		public var model:AppModel;
		
		private var client:Client;
		
		override public function execute():void {
			client  = event.args[0] as Client;
			service.removeClient(event.args[0] as Client);
			service.addHandlers(handleClientRemoved);
		}
		private function handleClientRemoved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				model.clients.removeItem(client);
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CLIENT_DELETED));
				
				///????? DELETE tables after datasets are deleted?
			}
		}
	}
}