package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Category;
	
	public interface IDataVisualizer extends IVisualizer
	{

		function pause():void;
		
		function resume():void;
		
		function updateYear(year:String):void;
		
		function get datasets():Array;
		
		function addCategory(value:Category,count:int):void;
		
		function removeCategory(value:Category,count:int):void;
		
		function selectCategory(value:Category):void;
		
		function selectAllCategories():void;
		
		function get didVisualize():Boolean;
		
		function selectCountries(countries:Vector.<Object>):void;
	}
}