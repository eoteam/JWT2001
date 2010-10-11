package com.pentagram.services
{
	
	import com.adobe.serialization.json.JSON;
	import com.darronschall.serialization.ObjectTranslator;
	
	import flash.net.URLRequestMethod;
	import flash.xml.XMLDocument;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.mxml.Concurrency;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ArrayUtil;
	
	internal class JSONHTTPService
	{
		public var service:HTTPService;
		public var decodeClass:Class;
		public var token:AsyncToken;
		public var params:Object;
		public function JSONHTTPService(url:String,params:Object,responseType:String,decodeClass:Class=null) {
					
			service = new HTTPService();
			service.method = URLRequestMethod.POST;
			service.url = url;
			service.showBusyCursor = false;
			service.resultFormat = HTTPService.RESULT_FORMAT_TEXT;
			service.concurrency = Concurrency.MULTIPLE;
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
		
		public function decode(event:ResultEvent):void
		{
			var temp:Array = ArrayUtil.toArray(JSON.decode(String(event.result)));
			var results:Array = [];
			for each(var item:Object in temp) 
			{
				var result:* = ObjectTranslator.objectToInstance(item, decodeClass);
				results.push(result);
				
			}
			token.results = results;
		}
//		protected function decodeData(xml:XMLDocument):Array {
//			var children:Array = [];
//			var xmlDecoder:SimpleXMLDecoder = new SimpleXMLDecoder();
//			if (xml.firstChild.childNodes.length > 0) {
//				var objectTree:Object = xmlDecoder.decodeXML(xml.firstChild);
//				var results:Array;
//				
//				if (objectTree.result is Array) 
//					results = objectTree.result;
//				else if(objectTree.result is Object)
//					results = [objectTree.result];
//				for (var i:int=0; i < results.length; i++) { 
//					var item:Object = ObjectTranslator.objectToInstance(results[i], decodeClass);
//					children.push(item);
//				}
//			}
//			return children;
//		}
//		protected function decodeStatus(xml:XMLDocument):StatusResult {
//			var children:Array = [];
//			var xmlDecoder:SimpleXMLDecoder = new SimpleXMLDecoder();
//			if (xml.firstChild.childNodes.length > 0) {
//				var objectTree:Object = xmlDecoder.decodeXML(xml.firstChild);
//				var result:StatusResult = new StatusResult();
//				for(var prop:String in objectTree)
//					result[prop] = objectTree[prop];
//			}
//			return result;
//		}
	}
}