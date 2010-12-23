package com.pentagram.services
{
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.interfaces.IDatasetService;
	
	import mx.utils.StringUtil;
	


	public class DatasetService extends AbstractService implements IDatasetService
	{
		[Inject]
		public var model:InstanceModel;
		
		public function loadDataSet(dataset:Dataset):void {
			var params:Object = new Object();
			params.action = "getData";
			params.tablename = dataset.tablename;
			this.createService(params,ResponseType.DATA,Object);				
		}
		
		public function createDataset(dataset:Dataset):void {
			var params:Object = new Object();
			params.action = "createDataset";
			params.contentid = model.client.id;
			params.tablename = String(model.client.shortname+'_'+ dataset.name.split(' ').join('')).toLowerCase();
			params.name = dataset.name;
			var countryids:String = '';
			for each(var country:Country in model.client.countries.source) {
				countryids += country.id.toString()+',';
			}
			countryids = countryids.substring(0,countryids.length-1);
			params.countryids = countryids;
			params.time = dataset.time;
			params.type = dataset.type;
			params.unit = dataset.unit;
			params.multiplier = dataset.multiplier;
			params.createdby = model.user.id;
			params.modifiedby = model.user.id;
			if(dataset.time == 1)
				params.years = dataset.years[0]+','+dataset.years[1];
			this.createService(params,ResponseType.STATUS);			
		}	
		public function deleteDataset(dataset:Dataset):void {
			var params:Object = new Object();
			params.action = "deleteDataset";
			params.tablename = dataset.tablename;
			params.id = dataset.id;
			this.createService(params,ResponseType.STATUS);			
		}
		public function updateDataset(dataset:Dataset):void {
			var params:Object = new Object();
			params.action = "updateRecord";
			params.tablename = "datasets";
			for each(var prop:String in dataset.modifiedProps) {
				params[prop] = dataset[prop];
			}
			params.id = dataset.id;
			this.createService(params,ResponseType.STATUS);				
		}
		public function updateDataRow(row:DataRow):void {
			var params:Object = new Object();
			params.action = "updateDatasetRow";
			params.tablename = row.dataset.tablename;
			params.countryid = row.country.id;
			for each(var prop:String in row.modifiedProps)
				params[prop.toString()] = row[prop];
			this.createService(params,ResponseType.STATUS);
		}
	}
}