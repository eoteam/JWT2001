package com.pentagram.controller.startup
{
	import com.pentagram.services.interfaces.IAppService;
	
	import org.robotlegs.mvcs.Command;

	public class LoadCountries extends Command
	{

		[Inject]
		public var appService:IAppService;
		
		override public function execute():void
		{
			appService.loadCountries();
		}
	}
}