package com.pentagram.instance.controller
{
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Region;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.services.interfaces.IDatasetService;
	import com.pentagram.services.interfaces.IInstanceService;
	import com.pentagram.util.ViewUtils;
	
	import mx.collections.ArrayList;
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class LoadClientCommand extends Command
	{
		[Inject]
		public var service:IInstanceService;
		
		[Inject]
		public var datasetService:IDatasetService;
		
		[Inject]
		public var event:VisualizerEvent;
		
		[Inject]
		public var model:InstanceModel;
		
		private var counter:int;
		override public function execute():void
		{
			counter = 0;
			if(!model.client.loaded) {
				service.loadClientDatasets();
				service.addHandlers(handleClientDatasets);
				service.loadClientCountries();
				service.addHandlers(handleClientCountries);	
			}
			else {
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED));
			}
		}
		private function handleClientDatasets(event:ResultEvent):void
		{
			var sets:Array = event.token.results as Array;
			model.client.datasets = new ArrayList(sets);
			if(sets.length > 0) {
				for each(var dataset:Dataset in model.client.datasets.source) {
					if(dataset.time == 1)
						dataset.years = dataset.range.split(',');
					if(dataset.options && dataset.options != '') {
						var arr:Array =  dataset.options.split(',');
						for each(var option:String in arr)
						dataset.optionsArray.push({item:option});
					}
						
					datasetService.loadDataSet(dataset);
					datasetService.addHandlers(handleDatasetLoaded);
					datasetService.addProperties("dataset",dataset);
				}
			}
			else {
				model.client.loaded = true;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED));
				
			}
			
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
		}
		private function handleDatasetLoaded(event:ResultEvent):void
		{
			counter++;
			var dataset:Dataset = event.token.dataset as Dataset;
			dataset.data = event.result.toString();
			dataset.loaded = true;
			model.parseData(event.token.results as Array,dataset,model.client);
			if(counter == model.client.datasets.length) {
				model.client.loaded = true;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED));
				//model.client = client;
			}
		}
		
	}
}