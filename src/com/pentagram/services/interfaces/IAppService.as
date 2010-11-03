package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Region;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Dataset;
	

	public interface IAppService extends IService
	{
		function loadCountries(continent:Region):void;
		
		function loadContinents():void;
		
		function loadClients():void;
				
		function authenticateUser(username:String,password:String):void;
		
		function logOut():void;
		
		
	}
}