package com.pentagram.services.interfaces
{
	import mx.rpc.AsyncToken;

	public interface IService
	{
		function addHandlers(resultHandler:Function,faultHandler:Function=null):void;
		
		function addProperties(prop:String, value:*):void;
		
		function get currentToken():AsyncToken;
		//function loadData(tablename:String, clazz:Class=null,...args):void;
	}
}