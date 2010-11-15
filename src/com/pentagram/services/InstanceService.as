package com.pentagram.services
{
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.interfaces.IInstanceService;

	public class InstanceService extends AbstractService implements IInstanceService
	{
		[Inject]
		public var model:InstanceModel;
		
		public function loadClientDatasets():void {
			var params:Object = new Object();
			params.action = "getData";
			params.tablename = "datasets";
			params.contentid = model.client.id;
			params.deleted = 0;
			this.createService(params,ResponseType.DATA,Dataset);
		}
		public function loadClientCountries():void {
			var params:Object = new Object();
			params.action = "getData";
			params.tablename = "client_countries";
			params.clientid = model.client.id;
			this.createService(params,ResponseType.DATA);	
		}
		public function saveClientInfo():void {
			var params:Object = new Object();
			for each(var prop:String in model.client.modifiedProps) {
				params[prop] = model.client[prop];
			}
			params.action = "updateRecord";
			params.tablename = "content";
			params.id = model.client.id;
			this.createService(params,ResponseType.STATUS);
		}
		public function addClientCountry(country:Country):void {
			var params:Object = new Object();
			params.action = "insertRecord";
			params.tablename = "client_countries";
			params.clientid = model.client.id;
			params.countryid = country.id;
			this.createService(params,ResponseType.STATUS);
		}
		public function removeClientCountry(country:Country):void {
			var params:Object = new Object();
			params.action = "removeRecord";
			params.tablename = "client_countries";
			params.clientid = model.client.id;
			params.countryid = country.id;
			this.createService(params,ResponseType.STATUS);
		}
	}
}