package com.pentagram.instance.view.visualizer
{
	import flare.vis.data.Data;
	
	import mx.core.IUIComponent;

	public interface IGraphView extends IUIComponent
	{
		function visualize(arr:Array,prop1:String,prop2:String,prop3:String):void;
		
		function update():void;
		
		function set visdata(data:Data):void;
		
		function get visdata():Data;
		
	}
}