package com.pentagram.controller.startup
{
	import com.pentagram.event.AppEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Continent;
	import com.pentagram.model.vo.Country;
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
			
			appService.loadClients();
			appService.addHandlers(handleClients);
		}
		private function handleClients(event:ResultEvent):void
		{
			appModel.clients = new ArrayList(event.token.results as Array);
			//eventDispatcher.dispatchEvent(new
			counter++;
			checkCount();
		}
		private function handleContinents(event:ResultEvent):void
		{
			var continents:Array = event.token.results as Array;
			appModel.continents = new ArrayList(continents);
			appModel.countries = new ArrayList();
			total +=  continents.length;
			counter++;
			for each(var continent:Continent in continents)
			{
				appService.loadCountries(continent);
				appService.addHandlers(handleCountries);
				appService.addProperties("continent",continent);
			}
		}
		private function handleCountries(event:ResultEvent):void
		{
			counter++;
			var countries:Array = event.result as Array;
			var continent:Continent = event.token.continent;
			continent.countries = new ArrayList(countries);
			for each(var country:Country in countries)
			{
				country.continent = continent;
				appModel.countries.addItem(country);
			}
			checkCount();
		}
		private function checkCount():void
		{
			if(counter == total) {
				eventDispatcher.dispatchEvent(new AppEvent(AppEvent.STARTUP_COMPLETE));	
			}
		}
	}
}