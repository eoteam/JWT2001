package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Client;

	public interface ITwitterView extends IVisualizer
	{		
		function set client(value:Client):void;
		
		function get topics():Array;
	}
}