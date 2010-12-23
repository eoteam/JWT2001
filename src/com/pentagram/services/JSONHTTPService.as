package com.pentagram.services
{
	
	import com.adobe.serialization.json.JSON;
	import com.darronschall.serialization.ObjectTranslator;
	
	import flash.net.URLRequestMethod;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.mxml.Concurrency;
	import mx.utils.ArrayUtil;
	
	internal class JSONHTTPService
	{
		public var service:HTTPService;
		public var decodeClass:Class;
		public var token:AsyncToken;
		public var params:Object;
		public var responseType:String;
		
		public function JSONHTTPService(url:String,params:Object,responseType:String,decodeClass:Class=null) {			
			service = new HTTPService();
			service.method = URLRequestMethod.POST;
			service.url = url;
			service.showBusyCursor = false;
			service.resultFormat = HTTPService.RESULT_FORMAT_TEXT;
			service.concurrency = Concurrency.MULTIPLE;
			this.responseType = responseType;
			//service.addEventListener(ResultEvent.RESULT,handleResults);
			//service.xmlDecode = (responseType == ResponseType.DATA) ? decodeData:decodeStatus;
			this.params = params;
			if(decodeClass)
				this.decodeClass = decodeClass;
			else
				this.decodeClass = Object;
		}	
		public function execute():void {
			if(params != null)
				token = service.send(params);
			else
				token = service.send();
			token.params = params;
		}
		
		public function decodeData(event:ResultEvent):void {
			var temp:Array = ArrayUtil.toArray(JSON.decode(String(event.result)));
			var results:Array = [];
			for each(var item:Object in temp) 
			{
				var result:* = ObjectTranslator.objectToInstance(item, decodeClass);
				results.push(result);
				
			}
			token.results = results;
			//token.raw = temp;
		}
		public function decodeStatus(event:ResultEvent):void {
			event.token.results = ObjectTranslator.objectToInstance(JSON.decode(event.result.toString()), StatusResult);
		}
	}
}