package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;

	public interface IInstanceService extends IService
	{
		function loadClientDatasets():void;
		
		function loadClientCountries():void;
		
		function saveClientInfo():void;
		
		function addClientCountry(country:Country):void;
		
		function removeClientCountry(country:Country):void;
	
	}
}