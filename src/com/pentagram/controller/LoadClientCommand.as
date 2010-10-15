package com.pentagram.controller
{
	import com.pentagram.event.VisualizerEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.services.interfaces.IAppService;
	
	import mx.collections.ArrayList;
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class LoadClientCommand extends Command
	{
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var event:VisualizerEvent;
		
		[Inject]
		public var appModel:AppModel;
		
		private var client:Client;
		private var counter:int;
		override public function execute():void
		{
 			client = event.args[0] as Client;
			appService.loadClientDatasets(client);
			appService.addHandlers(handleClientDatasets);
			appService.loadClientCountries(client);
			appService.addHandlers(handleClientCountries);
			
		}
		private function handleClientDatasets(event:ResultEvent):void
		{
			var sets:Array = event.token.results as Array;
			client.datasets = new ArrayList(sets);
			if(sets.length > 0) {
				for each(var dataset:Dataset in client.datasets.source) {
					appService.loadDataSet(dataset);
					appService.addHandlers(handleDatasetLoaded);
					appService.addProperties("dataset",dataset);
				}
			}
			else {
					eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED,client));
			}
			
		}
		private function handleClientCountries(event:ResultEvent):void
		{
			var relatedIds:Array = event.token.results as Array;
		}
		private function handleDatasetLoaded(event:ResultEvent):void
		{
			counter++;
			var dataset:Dataset = event.token.dataset as Dataset;
			dataset.loaded = true;
			dataset.data = event.result.toString();
			if(counter == client.datasets.length) {
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_DATA_LOADED,client));
				appModel.selectedClient = client;
			}
		}
		
	}
}