package com.pentagram.services
{
	import com.pentagram.controller.Constants;
	import com.pentagram.events.AlertEvent;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Actor;
	
	public class AbstractService extends Actor
	{

		protected var services:Array = [];
		protected var url:String = Constants.DB_EXECUTE;
		public function AbstractService() 
		{
			super();
		}		
		protected function result(event:ResultEvent):void {
			if(event.token.resultCallBack) {
				var service:JSONHTTPService = services[event.token.id] as JSONHTTPService;
				if(service.responseType == ResponseType.DATA)
					service.decodeData(event);
				else
					service.decodeStatus(event);
				event.token.resultCallBack(event);
			}
			delete services[event.token.id];
		}
		protected function fault(info:Object):void {
			eventDispatcher.dispatchEvent(new AlertEvent( AlertEvent.SHOW_ALERT, "crap","Crap"));
			delete services[info.token.id];
		}
		protected function createService(params:Object,responseType:String,decodeClass:Class=null,
										 resultFunction:Function=null,faultFunction:Function=null):JSONHTTPService {
		
			//var id:String = GUID.create();
			var service:JSONHTTPService = new JSONHTTPService(url,params,responseType,decodeClass);
			services.push(service);
			service.execute();
			service.token.id = services.indexOf(service);
			var faultHandler:Function = faultFunction==null?this.fault:faultFunction;
			var resultHandler:Function = resultFunction==null?this.result:resultFunction;
			service.token.addResponder(new Responder(resultHandler,faultHandler));
			if(resultFunction != null)
				service.token.addResponder(new Responder(result,fault));
			return service;
		}
		public function addHandlers(resultHandler:Function,faultHandler:Function=null):void {
			var service:JSONHTTPService = services[services.length-1];
			service.token.resultCallBack = resultHandler;
			service.token.faultCallBack = faultHandler;
		}
		public function addProperties(prop:String,value:*):void {
			var service:JSONHTTPService = services[services.length-1];
			service.token[prop] = value;
		}
		public function get currentToken():AsyncToken {
			return JSONHTTPService(services[services.length-1]).token ;
		}	
	}
}