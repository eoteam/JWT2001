package com.pentagram.instance.events
{
	import flash.events.Event;
	
	public class VisualizerEvent extends Event
	{
		
		public static const CLIENT_SELECTED:String = "clientSelected";
		public static const CLIENT_DATA_LOADED:String = "clientDataLoaded";

		public static const LOAD_SEARCH_VIEW:String = "loadSearchView";
		
		public static const REFRESH_VISUALIZER:String = "refreshVisualizer";
		
		
		public static const DATASET_SELECTION_CHANGE:String = "datasetSelectionChange";
		
		public static const PLAY_TIMELINE:String = "playTimeline";
		public static const STOP_TIMELINE:String = "stopTimeline";
		
		public static const CATEGORY_CHANGE:String = "categoryChange";
	
		public static const UPDATE_VISUALIZER_VIEW:String = "updateVisualizerView";
		
		public static const WINDOW_RESIZE:String = "windowResize";
		
		public static const TWITTER_SEARCH:String = "twitterSearch";
		public static const TWITTER_RELOAD:String = "twitterReload";
		public static const TWITTER_SORT:String = "twitterSort";
		
		
		public var args:Array;
		public function VisualizerEvent(type:String,...args)
		{
			this.args = args;
			super(type,true,true);
		}
		override public function clone() : Event
		{
			return new VisualizerEvent(this.type,this.args);
		}
	}
}