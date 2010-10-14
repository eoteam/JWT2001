package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Continent;
	import com.pentagram.model.vo.Dataset;
	

	public interface IAppService extends IService
	{
		function loadCountries(continent:Continent):void;
		
		function loadContinents():void;
		
		function loadClients():void;
		
		function loadClientData(client:Client):void;
		
		function loadDataSet(dataset:Dataset):void;
		
		function authenticateUser(username:String,password:String):void;
		
		function logOut():void;
	}
}