package com.pentagram.instance.view.visualizer
{
	import flare.vis.data.Data;
	
	import mx.core.IUIComponent;

	public interface IGraphView extends IUIComponent
	{
		function visualize(arr:Array,...props):void;
		
		function update():void;
		
		function set visdata(data:Data):void;
		
		function get visdata():Data;
		
		function updateMaxRadius(value:Number):void;
		
		function unload():void;
		
		function set continous(value:Boolean):void;
		
		function get continous():Boolean;
	}
}