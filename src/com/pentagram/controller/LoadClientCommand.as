package com.pentagram.controller
{
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.interfaces.IAppService;
	import com.pentagram.services.interfaces.IDatasetService;
	import com.pentagram.util.DataParser;
	
	import mx.collections.ArrayList;
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class LoadClientCommand extends Command
	{
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var datasetService:IDatasetService;
		
		[Inject]
		public var event:VisualizerEvent;
		
		[Inject]
		public var appModel:AppModel;

		private var counter:int;
		override public function execute():void
		{
			counter = 0;
			if(!appModel.selectedClient.loaded) {
				appService.loadClientDatasets();
				appService.addHandlers(handleClientDatasets);
				appService.loadClientCountries();
				appService.addHandlers(handleClientCountries);	
			}
			else {
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED));
			}
		}
		private function handleClientDatasets(event:ResultEvent):void
		{
			var sets:Array = event.token.results as Array;
			appModel.selectedClient.datasets = new ArrayList(sets);
			if(sets.length > 0) {
				for each(var dataset:Dataset in appModel.selectedClient.datasets.source) {
					if(dataset.time == 1)
						dataset.years = dataset.range.split(',');
					datasetService.loadDataSet(dataset);
					datasetService.addHandlers(handleDatasetLoaded);
					datasetService.addProperties("dataset",dataset);
				}
			}
			else {
				appModel.selectedClient.loaded = true;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED));
			}
			
		}
		private function handleClientCountries(event:ResultEvent):void
		{	
			var relatedIds:Array = event.token.results as Array;
			for each(var country:Country in appModel.countries.source) {
				for each(var relatedId:Object in relatedIds) {
					if(country.id.toString() == relatedId.countryid) {
						appModel.selectedClient.countries.addItem(country);
						break;
					}
				}
			}
		}
		private function handleDatasetLoaded(event:ResultEvent):void
		{
			counter++;
			var dataset:Dataset = event.token.dataset as Dataset;
			dataset.loaded = true;
			DataParser.parseData(event.token.results as Array,dataset,appModel.selectedClient);
			if(counter == appModel.selectedClient.datasets.length) {
				appModel.selectedClient.loaded = true;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED));
				//appModel.selectedClient = client;
			}
		}
		
	}
}