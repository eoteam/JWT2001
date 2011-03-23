package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Note;
	
	import mx.collections.ArrayList;

	public interface IClientService extends IService
	{
		function loadClientDatasets(client:Client):void;
		
		function loadClientCountries(client:Client):void;
		
		function saveClientInfo(client:Client):void;
		
		function addClientCountries(client:Client,countries:ArrayList):void;
		function removeClientCountries(client:Client,countries:ArrayList):void;
		
		function addDatasetCountries(dataset:Dataset,countries:ArrayList):void;
		function removeDatasetCountries(dataset:Dataset,countries:ArrayList):void;
		
		function createClient(client:Client,userid:int):void;	
		
		function removeClient(client:Client):void;
		
		function loadClientNotes(client:Client):void;
		
		function updateNote(note:Note):void;
		function createNode(note:Note):void;
		
		function getLatestDataset():void;
		
		
	}
}