package com.pentagram.instance.view.visualizer
{
	
	
	import mx.core.IUIComponent;

	public interface IGraphView extends IVisualizer
	{
		function visualize(arr:Array,...props):void;
		

	}
}