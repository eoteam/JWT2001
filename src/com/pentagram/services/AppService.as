package com.pentagram.services
{
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Continent;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.User;
	import com.pentagram.services.interfaces.IAppService;
	
	import flash.net.URLRequestMethod;
	
	import mx.rpc.Responder;
	import mx.rpc.http.HTTPService;
	
	public class AppService extends AbstractService implements IAppService
	{
		[Inject]
		public var appModel:AppModel;
		
		public function AppService() {
			super();
		}
		public function loadClients():void {
			var params:Object = new  Object();
			params.action = "getContent";
			params.verbosity = 4;
			params.parentid = 2;
			this.createService(params,ResponseType.DATA,Client);
		}		
		public function loadContinents():void {
			var params:Object = new  Object();
			params.action = "getContent";
			params.verbosity = 2;
			params.parentid = 3;
			this.createService(params,ResponseType.DATA,Continent);
		}
		public function loadCountries(continent:Continent):void {
			var params:Object = new  Object();
			params.action = "getContent";
			params.verbosity = 3;
			params.parentid = continent.id;
			this.createService(params,ResponseType.DATA,Country);		
		}
		public function loadClientDatasets():void {
			var params:Object = new Object();
			params.action = "getData";
			params.tablename = "datasets";
			params.contentid = appModel.selectedClient.id;
			params.deleted = 0;
			this.createService(params,ResponseType.DATA,Dataset);	
		}
		public function loadClientCountries():void {
			var params:Object = new Object();
			params.action = "getData";
			params.tablename = "client_countries";
			params.clientid = appModel.selectedClient.id;
			this.createService(params,ResponseType.DATA);	
		}

		public function authenticateUser(username:String, password:String):void {
			var params:Object = new Object();
			params.username = username;
			params.password = password;
			params.action = "validateUser";	
			this.createService(params,ResponseType.DATA,User);
		}
		public function logOut():void {
			
		}
		public function saveClientInfo():void {
			var params:Object = new Object();
			for each(var prop:String in appModel.selectedClient.modifiedProps) {
				params[prop] = appModel.selectedClient[prop];
			}
			params.action = "updateRecord";
			params.tablename = "content";
			params.id = appModel.selectedClient.id;
			this.createService(params,ResponseType.STATUS);
		}
		public function addClientCountry(country:Country):void {
			var params:Object = new Object();
			params.action = "insertRecord";
			params.tablename = "client_countries";
			params.clientid = appModel.selectedClient.id;
			params.countryid = country.id;
			this.createService(params,ResponseType.STATUS);
		}
		public function removeClientCountry(country:Country):void {
			var params:Object = new Object();
			params.action = "removeRecord";
			params.tablename = "client_countries";
			params.clientid = appModel.selectedClient.id;
			params.countryid = country.id;
			this.createService(params,ResponseType.STATUS);
		}
	}
}