package com.pentagram.instance.view.visualizer.interfaces
{
	import com.pentagram.model.vo.Client;

	public interface ITwitterView extends IVisualizer
	{		
		function set searchTerm(q:String):void;
		
		function get topics():Array;
		
		function selectTweets(tweets:Vector.<Object>):void;
		
		function changeView(view:Object):void;
		 
	}
}