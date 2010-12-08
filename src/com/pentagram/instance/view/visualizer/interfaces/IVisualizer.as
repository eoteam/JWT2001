package com.pentagram.instance.view.visualizer.interfaces
{

	
	public interface IVisualizer
	{
		function update():void;
				
		function updateMaxRadius(value:Number):void;
		
		function unload():void;
		
		function set continous(value:Boolean):void;
		
		function get continous():Boolean;
		
		function pause():void;
		
		function resume():void;
		
		function updateYear(year:int):void;
		
		function toggleOpacity(value:Number):void;
		
	}
}