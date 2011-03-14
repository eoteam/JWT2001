package com.pentagram.instance.view.visualizer.interfaces
{
	import mx.core.IDataRenderer;
	import mx.core.IVisualElement;

	public interface IRendererInfo extends IVisualElement
	{
		function close():void;
		
		function set content(value:String):void;
		
		function get content():String;
		
		function get pinned():Boolean;
		
		function get data():Object;
		
		function set data(value:Object):void;
	}
}