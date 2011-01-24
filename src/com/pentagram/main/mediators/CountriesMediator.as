package com.pentagram.main.mediators
{
	import com.pentagram.main.windows.CountriesWindow;
	import com.pentagram.model.AppModel;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class CountriesMediator extends Mediator
	{
		[Inject]
		public var view:CountriesWindow;
		
		[Inject]
		public var model:AppModel;
		
		override public function onRegister():void {
			view.countryList.dataProvider = model.countries;
			view.continentList.dataProvider = model.regions;
		}
	}
}