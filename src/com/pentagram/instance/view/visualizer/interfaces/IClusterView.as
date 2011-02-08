package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Dataset;

	
	public interface IClusterView extends IDataVisualizer
	{
		function visualize(dataset1:Dataset,dataset2:Dataset=null):void;
	}
}