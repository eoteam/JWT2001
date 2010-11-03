package com.pentagram.controller.startup
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Region;
	import com.pentagram.services.interfaces.IAppService;
	
	import mx.collections.ArrayList;
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;

	public class StartupCommand extends Command
	{

		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var appModel:AppModel;
		
		private var counter:int;
		private var total:int;
		override public function execute():void
		{
			total = 2;
			appService.loadContinents();
			appService.addHandlers(handleContinents);
		}
		private function handleContinents(event:ResultEvent):void
		{
			var continents:Array = event.token.results as Array;
			appModel.regions = new ArrayList(continents);
			appModel.countries = new ArrayList();
			total +=  continents.length;
			counter++;
			for each(var continent:Region in continents)
			{
				appService.loadCountries(continent);
				appService.addHandlers(handleCountries);
				appService.addProperties("continent",continent);
			}
			appService.loadClients();
			appService.addHandlers(handleClients);
		}
		private function handleClients(event:ResultEvent):void
		{
			appModel.clients = new ArrayList(event.token.results as Array);
			counter++;
			for each(var client:Client in appModel.clients.source) {
				for each(var region:Region in appModel.regions.source) {
					var cRegion:Region = new Region();
					cRegion.color = region.color;
					cRegion.id = region.id;
					cRegion.name = region.name;
					cRegion.countries = new ArrayList();
					client.regions.addItem(cRegion);
				}
			}
			checkCount();
		}
		private function handleCountries(event:ResultEvent):void
		{
			counter++;
			var countries:Array = event.token.results as Array;
			var region:Region = event.token.continent;
			region.countries = new ArrayList(countries);
			for each(var country:Country in countries)
			{
				country.region = region;
				appModel.countries.addItem(country);
			}
			checkCount();
		}
		private function checkCount():void
		{
			//trace("#######################",counter,total,"#######################");
			if(counter == total) {
				trace("#######################APP STARTED#######################");
				eventDispatcher.dispatchEvent(new AppEvent(AppEvent.STARTUP_COMPLETE));	
			}
		}
	}
}