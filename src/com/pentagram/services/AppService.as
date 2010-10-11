package com.pentagram.services
{
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Continent;
	import com.pentagram.model.vo.Country;
	import com.pentagram.services.interfaces.IAppService;
	
	import flash.net.URLRequestMethod;
	
	import mx.rpc.Responder;
	import mx.rpc.http.HTTPService;
	
	public class AppService extends AbstractService implements IAppService
	{
		public function AppService() {
			super();
		}
		public function loadClients():void
		{
			var params:Object = new  Object();
			params.action = "getContent";
			params.verbosity = 4;
			params.parentid = 2;
			this.createService(params,ResponseType.DATA,Client);
		}		
		public function loadContinents():void
		{
			var params:Object = new  Object();
			params.action = "getContent";
			params.verbosity = 2;
			params.parentid = 3;
			this.createService(params,ResponseType.DATA,Continent);
		}
		public function loadCountries(continent:Continent):void
		{
			var params:Object = new  Object();
			params.action = "getContent";
			params.verbosity = 3;
			params.parentid = continent.id;
			this.createService(params,ResponseType.DATA,Country);		
		}

		
	}
}