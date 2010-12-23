package com.pentagram.services
{
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Region;
	import com.pentagram.model.vo.User;
	import com.pentagram.services.interfaces.IAppService;
	
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
			params.orderby = "width";
			this.createService(params,ResponseType.DATA,Region);
		}
		public function loadCountries(continent:Region):void {
			var params:Object = new  Object();
			params.action = "getContent";
			params.verbosity = 3;
			params.parentid = continent.id;
			this.createService(params,ResponseType.DATA,Country);		
		}
		public function loadColors():void {
			var params:Object = new  Object();
			params.action = "getData";
			params.tablename = 'colors';
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
		
	}
}