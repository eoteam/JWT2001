package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Dataset;

	public interface IDataService extends IService
	{
		function createDataset(dataset:Dataset):void;
			
		function deleteDataset(dataset:Dataset):void;
		
		function updateDataset(dataset:Dataset):void;
	}
}