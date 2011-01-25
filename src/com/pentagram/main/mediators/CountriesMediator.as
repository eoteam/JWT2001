package com.pentagram.main.mediators
{
	import com.pentagram.main.windows.CountriesWindow;
	import com.pentagram.model.AppModel;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class CountriesMediator extends Mediator
	{
		[Inject]
		public var view:CountriesWindow;
		
		[Inject]
		public var model:AppModel;
		
		override public function onRegister():void {
			view.countryList.dataProvider = new ArrayCollection(model.countries.source);
			view.continentList.dataProvider = model.regions;
		}
	}
}