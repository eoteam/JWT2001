package com.pentagram.instance.view.visualizer
{
	import flare.vis.data.Data;
	
	public interface IVisualizer
	{
		function update():void;
		
		function set visdata(data:Data):void;
		
		function get visdata():Data;
		
		function updateMaxRadius(value:Number):void;
		
		function unload():void;
		
		function set continous(value:Boolean):void;
		
		function get continous():Boolean;
		
		function pause():void;
		
		function resume():void;
	}
}