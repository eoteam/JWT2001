package com.pentagram.services.interfaces
{
	import com.pentagram.model.vo.Dataset;
	
	public interface IDatasetService extends IService
	{
		function createDataset(dataset:Dataset):void;
		
		function deleteDataset(dataset:Dataset):void;
	}
}