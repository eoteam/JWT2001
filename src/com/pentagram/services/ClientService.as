package com.pentagram.services
{
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.interfaces.IClientService;
	
	import mx.collections.ArrayList;

	public class ClientService extends AbstractService implements IClientService
	{
//		[Inject]
//		public var model:InstanceModel;
		
		public function loadClientDatasets(client:Client):void {
			var params:Object = new Object();
			params.action = "getData";
			params.tablename = "datasets";
			params.contentid = client.id;
			params.deleted = 0;
			this.createService(params,ResponseType.DATA,Dataset);
		}
		public function loadClientCountries(client:Client):void {
			var params:Object = new Object();
			params.action = "getData";
			params.tablename = "client_countries";
			params.clientid = client.id;
			this.createService(params,ResponseType.DATA);	
		}
		public function saveClientInfo(client:Client):void {
			var params:Object = new Object();
			for each(var prop:String in client.modifiedProps) {
				params[prop] = client[prop];
			}
			params.action = "updateRecord";
			params.tablename = "content";
			params.id = client.id;
			this.createService(params,ResponseType.STATUS);
		}
		public function addClientCountries(client:Client,countries:ArrayList):void {
			var params:Object = new Object();
			params.action = "insertRecordsByKey";
			params.tablename = "client_countries";
			params.clientid = client.id;
			params.manyfield = 'countryid';
			var manyids:String = '';
			for each(var country:Country in countries.source)
				manyids += country.id+',';
			manyids = manyids.substr(0,manyids.length-1);
			params.manyids = manyids;
			this.createService(params,ResponseType.DATA);
		}
		public function addDatasetCountries(dataset:Dataset,countries:ArrayList):void {
			var params:Object = new Object();
			params.action = "insertRecordsByKey";
			params.tablename = dataset.tablename;
			params.manyfield = 'countryid';
			var manyids:String = '';
			for each(var country:Country in countries.source)
				manyids += country.id+',';
			manyids = manyids.substr(0,manyids.length-1);
			params.manyids = manyids;
			this.createService(params,ResponseType.DATA);			
		}

		
		public function removeClientCountries(client:Client,countries:ArrayList):void {
			var params:Object = new Object();
			params.action = "deleteRecords";
			params.tablename = "client_countries";
			params.clientid = client.id;
			params.idfield = 'countryid';
			var manyids:String = '';
			for each(var country:Country in countries.source)
				manyids += country.id+',';
			manyids = manyids.substr(0,manyids.length-1);
			params.idvalues = manyids;
			this.createService(params,ResponseType.STATUS);
		}
		public function removeDatasetCountries(dataset:Dataset,countries:ArrayList):void {
			var params:Object = new Object();
			params.action = "deleteRecords";
			params.tablename = dataset.tablename;
			params.idfield = 'countryid';
			var manyids:String = '';
			for each(var country:Country in countries.source)
				manyids += country.id+',';
			manyids = manyids.substr(0,manyids.length-1);
			params.idvalues = manyids;
			this.createService(params,ResponseType.DATA);			
		}	
	}
}