package com.pentagram.services
{
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.interfaces.IDatasetService;

	public class DatasetService extends AbstractService implements IDatasetService
	{
		[Inject]
		public var appModel:AppModel;
		
		public function createDataset(dataset:Dataset):void {
			var params:Object = new Object();
			params.action = "createDataset";
			params.contentid = appModel.selectedClient.id;
			params.tablename = appModel.selectedClient.shortname+'_'+dataset.name;
			params.name = dataset.name;
			var countryids:String = '';
			for each(var country:Country in appModel.selectedClient.countries.source) {
				countryids += country.id.toString()+',';
			}
			countryids = countryids.substring(0,countryids.length-1);
			params.countryids = countryids;
			params.time = dataset.time;
			params.type = dataset.type;
			params.unit = dataset.unit;
			params.multiplier = dataset.multiplier;
			params.createdby = appModel.user.id;
			params.modifiedby = appModel.user.id;
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
	}
}