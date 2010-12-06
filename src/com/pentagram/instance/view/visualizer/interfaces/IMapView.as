package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Dataset;
	
	import mx.core.IUIComponent;

	public interface IMapView extends IVisualizer
	{
		function toggleMap(visible:Boolean):void;
	
		function visualize(dataset:Dataset):void;
		
	}
}