package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Region;
	
	import mx.core.IUIComponent;

	public interface IMapView extends IVisualizer
	{
		function toggleMap(visible:Boolean):void;
	
		function visualize(dataset:Dataset):void;
		
		function selectRegion(region:Region):void;
		
		function addRegion(region:Region):void;
		
		function removeRegion(region:Region):void;
		
		function set client(value:Client):void;
	}
}