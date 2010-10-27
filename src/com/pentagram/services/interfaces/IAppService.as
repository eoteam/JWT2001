package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Continent;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Dataset;
	

	public interface IAppService extends IService
	{
		function loadCountries(continent:Continent):void;
		
		function loadContinents():void;
		
		function loadClients():void;
		
		function loadClientDatasets():void;
		
		function loadClientCountries():void;
				
		function authenticateUser(username:String,password:String):void;
		
		function logOut():void;
		
		function saveClientInfo():void;
		
		function addClientCountry(country:Country):void;
		
		function removeClientCountry(country:Country):void;
		
	}
}