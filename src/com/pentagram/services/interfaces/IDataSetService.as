package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	
	public interface IDatasetService extends IService
	{
		function loadDataSet(dataset:Dataset):void;
		
		function createDataset(dataset:Dataset):void;
		
		function deleteDataset(dataset:Dataset):void;
		
		function updateDataset(dataset:Dataset):void;
		
		function updateDataRow(row:DataRow):void;
	}
}