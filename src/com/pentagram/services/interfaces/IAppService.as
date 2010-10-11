package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Continent;
	

	public interface IAppService extends IService
	{
		function loadCountries(continent:Continent):void;
		
		function loadContinents():void;
		
		function loadClients():void;
	}
}