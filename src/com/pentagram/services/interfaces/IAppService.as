package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.BaseVO;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Region;
	

	public interface IAppService extends IService
	{
		function loadCountries(continent:Region):void;
		
		function loadContinents():void;
		
		function loadClients():void;
		
		function loadColors():void;
		
		function authenticateUser(username:String,password:String):void;
		
		function logOut():void;
		
		function saveCountry(country:Country):void;
		
		function createCountry(country:Country):void;
		
		function deleteVO(vo:BaseVO):void;
		
		function addFileToDatabase(file:Object,path:String):void;
		
		function addFileToContent(contentid:int,mediaid:int):void;
		
	}
}