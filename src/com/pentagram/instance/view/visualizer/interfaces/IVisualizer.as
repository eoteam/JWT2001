package com.pentagram.instance.view.visualizer.interfaces
{
	public interface IVisualizer
	{
		function update():void;
		
		function updateSize():void;		
		
		function get viewOptions():Array;
		
		function toggleOpacity(value:Number):void;
		
		function updateMaxRadius(value:Number):void;
		
	}
}