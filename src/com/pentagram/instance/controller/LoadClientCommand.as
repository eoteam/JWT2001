package com.pentagram.instance.controller
{
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Region;
	import com.pentagram.services.interfaces.IClientService;
	import com.pentagram.services.interfaces.IDatasetService;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class LoadClientCommand extends Command
	{
		[Inject]
		public var service:IClientService;
		
		[Inject]
		public var datasetService:IDatasetService;
		
		[Inject]
		public var event:VisualizerEvent;
		
		[Inject]
		public var model:InstanceModel;
		
		private var counter:int;
		private var total:int;
		
		override public function execute():void
		{
			counter = 0;
			if(!model.client.loaded) {
				service.loadClientDatasets(model.client);
				service.addHandlers(handleClientDatasets);
				service.loadClientCountries(model.client);
				service.addHandlers(handleClientCountries);	
				service.loadClientNotes(model.client);
				service.addHandlers(handleClientNotes);	
				total = 3;
			}
			else {
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED));
			}
		}
		private function handleClientDatasets(event:ResultEvent):void
		{
			var sets:Array = event.token.results as Array;
			model.client.datasets = new ArrayList(sets);
			model.client.qualityDatasets = new ArrayList();
			model.client.quantityDatasets = new ArrayList();			
			if(sets.length > 0) {
				total+= sets.length;
				for each(var dataset:Dataset in model.client.datasets.source) {
					if(dataset.time == 1)
						dataset.years = dataset.range.split(',');
					if(dataset.options && dataset.options != '') {
						var arr:Array =  dataset.options.split(',');
						for(var i:int=0;i<arr.length;i++) {
							var option:Category = new Category();
							option.name = arr[i];
							option.color= model.colors[i];
							dataset.optionsArray.push(option);
							dataset.colorArray[option.name] = option.color;
						}
					}
					if(dataset.type == 1)
						model.client.quantityDatasets.addItem(dataset);
					else
						model.client.qualityDatasets.addItem(dataset);
					
					datasetService.loadDataSet(dataset);
					datasetService.addHandlers(handleDatasetLoaded);
					datasetService.addProperties("dataset",dataset);
				}
			}


			checkCount();
		}
		private function handleClientCountries(event:ResultEvent):void
		{	
			var relatedIds:Array = event.token.results as Array;
			for each(var country:Country in model.countries.source) {
				for each(var relatedId:Object in relatedIds) {
					if(country.id.toString() == relatedId.countryid) {
						model.client.countries.addItem(country);
						for each(var region:Region in model.client.regions.source) {
							if(country.region.id == region.id) {
								region.countries.addItem(country);
								break;
							}
						}
						break;
					}
				}
			}

			checkCount();
		}
		private function handleClientNotes (event:ResultEvent):void {
			var notes:Array = event.token.results as Array;
			model.client.notes.source = notes;

			checkCount();
		}
		private function handleDatasetLoaded(event:ResultEvent):void {
			//trace("Dataset counter",counter,model.client.datasets.length);
			var dataset:Dataset = event.token.dataset as Dataset;
			dataset.data = event.result.toString();
			dataset.loaded = true;
			model.parseData(event.token.results as Array,dataset,model.client);
			
			var sortField:SortField = new SortField();
			sortField.name = "id";
			sortField.numeric = true;
			var countrySort:Sort = new Sort();
			countrySort.fields = [sortField];
			countrySort.compareFunction = orderCountriesById;
			dataset.rows.sort = countrySort;
			dataset.rows.refresh();
			
			checkCount();
		}
		private function addNoneSets():void {
			var none:Dataset = new Dataset();
			none.name = "None";
			none.id = -1;
			for each(var country:Country in model.client.countries.source) {
				var row:DataRow = new DataRow();
				row.country = country;
				row.dataset = none;
				row.id = -1;
				row.color = country.region.color;
				row.name = country.name;
				none.rows.addItem(row);
			}
			
			model.client.datasets.addItemAt(none,0);
			model.client.qualityDatasets.addItemAt(none,0);
			model.client.quantityDatasets.addItemAt(none,0);
		}
		private  function orderCountriesById(a:DataRow, b:DataRow,fields:Array = null):int 
		{ 	
			if (a.id < b.id)  
				return -1; 
				
			else if (a.id > b.id)  
				return 1; 
				
			else 
				return 0; 
			
		} 
		private function checkCount():void {
			counter++;
			if(counter == total) {
				model.client.loaded = true;
				addNoneSets();
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED));
				trace("CLIENT LOADED");
			}
		}
	}
}