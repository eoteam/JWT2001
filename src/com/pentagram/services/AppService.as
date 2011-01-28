package com.pentagram.services
{
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.BaseVO;
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
		public function saveCountry(country:Country):void {
			var params:Object = new  Object();
			for each(var prop:String in country.modifiedProps) {
				if(prop != "region")
					params[prop] = country[prop];
				else
					params.parentid = country.region.id;
			}
			params.action = "updateRecord";
			params.tablename = "content";
			params.id = country.id;
			var d:Date = new Date();
			params.modifiedby = appModel.user.id;
			params.modifieddate = Math.floor(d.time / 1000);
			this.createService(params,ResponseType.STATUS);
		}
		public function addFileToDatabase(file:Object,path:String):void{
			var params:Object = new  Object();
			params.action = "insertRecord";
			params.tablename = 'media';
			params.name = file.name;
			params.path = path;
			params.extension = file.extension;
			params.size = file.size;
			params.width = file.width;
			params.height = file.height;
			params.mimetypeid = 1;
			params.createdby = params.modifiedby = appModel.user.id;
			var d:Date = new Date();
			params.createdate = params.modifieddate = Math.floor(d.time / 1000);
			this.createService(params,ResponseType.STATUS);
		}
		public function addFileToContent(contentid:int,mediaid:int):void {
			var params:Object = new  Object();
			params.action = "insertRecord";
			params.tablename = 'content_media';
			params.contentid = contentid;
			params.mediaid = mediaid;
			params.statusid = 4;
			this.createService(params,ResponseType.STATUS);			
		}
		public function createCountry(country:Country):void {
			var params:Object = new  Object();
			params.action = "insertRecord";
			params.tablename = 'content';
			params.name = country.name;
			params.shortname = country.shortname;
			params.parentid = country.region.id;
			params.templateid = 4;
			params.migtitle = country.name;
			params.createdby = params.modifiedby = appModel.user.id;
			var d:Date = new Date();
			params.createdate = params.modifieddate = Math.floor(d.time / 1000);
			this.createService(params,ResponseType.STATUS);
		}
		public function deleteVO(vo:BaseVO):void { //country,client,user
			var params:Object = new  Object();
			params.action = "deleteRecord";
			params.tablename = 'content';
			params.id = vo.id;
			this.createService(params,ResponseType.STATUS);
		}
		
	}
}