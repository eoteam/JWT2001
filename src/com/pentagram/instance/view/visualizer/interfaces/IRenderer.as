package com.pentagram.instance.view.visualizer.interfaces
{
	import mx.core.IDataRenderer;

	public interface IRenderer extends IDataRenderer
	{
		function toggleInfo(visible:Boolean):void;
		
		function draw():void;
		
		function set content(value:String):void;
		
		function moveInfo():void;
		
	}
}