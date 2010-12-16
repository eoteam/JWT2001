package com.pentagram.instance.view.visualizer.interfaces
{
		
	import mx.collections.ArrayCollection;

	public interface IGraphView extends IVisualizer
	{
		function set visdata(data:ArrayCollection):void;
		
		function get visdata():ArrayCollection;
		
		function visualize(maxRadius:Number,arr:ArrayCollection,...props):void;
	}
}