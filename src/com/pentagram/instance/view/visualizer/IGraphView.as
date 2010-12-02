package com.pentagram.instance.view.visualizer
{
	
	import flare.vis.data.Data;

	public interface IGraphView extends IVisualizer
	{
		function set visdata(data:Data):void;
		
		function get visdata():Data;
		
		function visualize(arr:Array,...props):void;
		

	}
}