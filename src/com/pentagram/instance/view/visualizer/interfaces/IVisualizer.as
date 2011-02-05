package com.pentagram.instance.view.visualizer.interfaces
{

	import com.pentagram.model.vo.Category;
	public interface IVisualizer
	{
		function update():void;
				
		function updateMaxRadius(value:Number):void;
		
		function unload():void;
			
		function pause():void;
		
		function resume():void;
		
		function updateYear(year:int):void;
		
		function toggleOpacity(value:Number):void;
		
		function get datasets():Array;
		
		function get viewOptions():Array;
				
		function addCategory(value:Category,count:int):void;
		
		function removeCategory(value:Category,count:int):void;
		
		function selectCategory(value:Category):void;
		
		function selectAllCategories():void;
		
		
		function updateSize():void;
		
		
	}
}