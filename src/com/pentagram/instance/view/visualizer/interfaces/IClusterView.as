package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Dataset;
	
	public interface IClusterView extends IVisualizer
	{
		function visualize(dataset1:Dataset,dataset2:Dataset=null):void;
	}
}