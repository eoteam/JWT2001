package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	
	import mx.collections.ArrayList;

	public interface IInstanceService extends IService
	{
		function loadClientDatasets():void;
		
		function loadClientCountries():void;
		
		function saveClientInfo():void;
		
		function addClientCountries(countries:ArrayList):void;
		function removeClientCountries(ountries:ArrayList):void;
		
		function addDatasetCountries(dataset:Dataset,countries:ArrayList):void;
		function removeDatasetCountries(dataset:Dataset,countries:ArrayList):void;
		
	
	}
}