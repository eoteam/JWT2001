package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Client;

	public interface ITwitterView extends IVisualizer
	{		
		function set searchTerm(q:String):void;
		
		function get topics():Array;
		
		function selectTweets(tweets:Vector.<Object>):void;
		
		function changeView(view:Object):void;
		
		function reload():void;
		
		function sort():void; 
		
		function showOptions(value:Boolean):void;
		
		function set state(value:String):void;
		
		function set colors(arr:Vector.<uint>):void;
	}
}