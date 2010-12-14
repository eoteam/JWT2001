package com.pentagram.instance.view.visualizer.interfaces
{
	
	import flare.vis.data.Data;
	
	import mx.collections.ArrayCollection;

	public interface IGraphView extends IVisualizer
	{
		function set visdata(data:ArrayCollection):void;
		
		function get visdata():ArrayCollection;
		
		function visualize(arr:ArrayCollection,...props):void;
	}
}