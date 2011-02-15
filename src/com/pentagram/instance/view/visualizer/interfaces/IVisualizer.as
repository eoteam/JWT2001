package com.pentagram.instance.view.visualizer.interfaces
{
	import flash.events.IEventDispatcher;

	public interface IVisualizer extends IEventDispatcher
	{
		function update():void;
		
		function updateSize():void;		
		
		function get viewOptions():Array;
		
		function toggleOpacity(value:Number):void;
		
		function updateMaxRadius(value:Number):void;
		
		function clearTooltips():void;
		
	}
}