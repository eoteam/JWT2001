package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Region;
	
	import mx.core.IUIComponent;

	public interface IMapView extends IVisualizer
	{
		function toggleMap(visible:Boolean):void;
	
		function visualize(dataset:Dataset):void;
		
		function toggleCategory(region:Region):void;
	}
}