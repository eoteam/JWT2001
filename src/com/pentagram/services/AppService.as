package com.pentagram.services
{
	import com.pentagram.model.AppModel;
	import com.pentagram.services.interfaces.IAppService;
	
	import flash.net.URLRequestMethod;
	
	import mx.rpc.Responder;
	import mx.rpc.http.HTTPService;
	
	public class AppService extends AbstractService implements IAppService
	{
		//[Inject]
		//public var appModel:AppModel;
		
		public function AppService() {
			super();
		}

		public function loadCountries():void {
			var params:Object = new  Object();
			params.action = "getContent";
			params.verbosity = "1";
			params.parentid = 3;
			this.createService(params,ResponseType.DATA);
		}
		public function loadContinents():void {

		}
		public function loadClients():void {
			
		}
		

	}
}