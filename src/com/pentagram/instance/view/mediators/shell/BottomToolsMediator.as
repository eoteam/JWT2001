package com.pentagram.instance.view.mediators.shell
{
	import com.flexoop.utilities.dateutils.DateUtils;
	import com.pentagram.events.ViewEvent;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.model.vo.Year;
	import com.pentagram.instance.view.shell.BottomTools;
	import com.pentagram.instance.view.shell.Shell;
	import com.pentagram.model.vo.Dataset;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.codec.PNGEncoder;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	
	public class BottomToolsMediator extends Mediator
	{
		[Inject]
		public var view:BottomTools;
		
		[Inject]
		public var model:InstanceModel;
		
		private var yearTimer:Timer;
		private var counter:uint = 0;
		private var normalizedData:Array;
		private var maxRadius:Number = 25;
		private var twitterCreated:Boolean = false;
		
		override public function onRegister():void
		{
			
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientLoaded,VisualizerEvent);
			
			eventMap.mapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleIndexChanged,IndexChangedEvent);	
			
			eventMap.mapListener(view.firstSet,IndexChangeEvent.CHANGE,handleDatasetSelection,IndexChangeEvent);
			eventMap.mapListener(view.secondSet,IndexChangeEvent.CHANGE,handleDatasetSelection,IndexChangeEvent);
			eventMap.mapListener(view.thirdSet,IndexChangeEvent.CHANGE,handleDatasetSelection,IndexChangeEvent);
			eventMap.mapListener(view.fourthSet,IndexChangeEvent.CHANGE,handleDatasetSelection,IndexChangeEvent);	
			
			eventMap.mapListener(view.yearSlider,IndexChangeEvent.CHANGE,handleYearSelection,IndexChangeEvent); 
			eventMap.mapListener(view.playBtn,MouseEvent.CLICK,handlePlayButton,MouseEvent);
			eventMap.mapListener(view.pdfBtn,MouseEvent.CLICK,saveImage,MouseEvent);
			eventMap.mapListener(view,MouseEvent.CLICK,closeSettingsPanel,MouseEvent);
						
			eventMap.mapListener(eventDispatcher,ViewEvent.UPDATE_TIMELINE,handleTimeline,ViewEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CATEGORY_CHANGE,handleCategoryChange,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
						
			yearTimer = new Timer(700);
			yearTimer.addEventListener(TimerEvent.TIMER,handleTimer);
		}
		private function handleClientLoaded(event:Event):void {
			if(view.yearSlider && view.yearSlider.dataProvider) {
				view.yearSlider.dataProvider = null;
				view.timelineContainer.visible = false;
			}
		}
		private function handleCategoryChange(event:VisualizerEvent):void {
			if(view.visualizerArea.selectedIndex == 0) {
				if(yearTimer.running) {
					yearTimer.stop();
					view.yearSlider.selectedIndex=0;
					view.playBtn.selected = view.loopBtn.selected = false;
				}
			}
		}
		private function saveImage(event:Event):void {	
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.START_IMAGE_SAVE));
		}
		private function closeSettingsPanel(event:MouseEvent):void {
			if(event.target != view.settingsBtn)
				view.settingsBtn.selected = false;
		} 			
					
		private function handleIndexChanged(event:IndexChangedEvent):void {
			if(yearTimer.running) {
				yearTimer.stop();
				view.yearSlider.selectedIndex=0;
				view.playBtn.selected = view.loopBtn.selected = false;
			}
			switch(view.visualizerArea.selectedIndex) {
				case model.CLUSTER_INDEX:
					view.currentState = 'cluster';
					view.thirdSet.dataProvider.getItemAt(0).name = "Region";
				break;
				
				case model.MAP_INDEX:
					view.currentState = 'map';	
					view.thirdSet.dataProvider.getItemAt(0).name = "Region";
				break;					
				
				case model.GRAPH_INDEX:
					view.currentState = 'graph';
					view.thirdSet.dataProvider.getItemAt(0).name = "None";
				break;	
				
				case model.TWITTER_INDEX:	
					view.currentState = 'twitter';
					if(!twitterCreated){
						twitterCreated = true;
						eventMap.mapListener(view.twitterOptions,DropDownEvent.CLOSE,handleDatasetSelection,DropDownEvent);
						eventMap.mapListener(view.twitterSearch,FlexEvent.ENTER,handleTwitterSearch,FlexEvent);
						eventMap.mapListener(view.reloadVisualization,MouseEvent.CLICK,handleReload,MouseEvent);
						eventMap.mapListener(view.twitterOptionsBtn,MouseEvent.CLICK,handleReload,MouseEvent);
					}
				break;	
			}
		}	
		private function handleTimeline(event:ViewEvent):void {
			updateTimeline(event);
		}
		private function updateTimeline(...args):ArrayList {
			var datasets:Array;
			var year:String;
			var selectedYear:Year;
			var y:String;
			if(args[0] is ViewEvent) {
				datasets = ViewEvent(args[0]).args[0] as Array;
				if( ViewEvent(args[0]).args.length > 1)
					y =  ViewEvent(args[0]).args[1];
			}
			else datasets = args;
			
			var years:ArrayList = new ArrayList();
			var uniqueYears:Dictionary = new Dictionary();
			var count:int;
			for each(var dataset:Dataset in datasets) {
				if(dataset.time == 1) {	
					count++;
					for (var i:int=0;i<dataset.years.length;i++) {
						year = dataset.years[i];
						if(uniqueYears[year])
							uniqueYears[year] += 1;
						else uniqueYears[year] = 1;
					}
				}
			}
			var ys:Array = [];
			for (year in uniqueYears) {
				if(uniqueYears[year] >= count)
					ys.push(year);
			}
			ys.sort();
			for each(year in ys) {
				var yy:Year = new Year(year,year.split('_').join('-'),1);
				years.addItem(yy); 	
				if(y!= null && year == y)
					selectedYear = yy;
				}
			view.yearSlider.dataProvider = years;
			view.yearSlider.selectedIndex = selectedYear?years.getItemIndex(selectedYear):0;
			view.yearSlider.invalidateDisplayList();
			view.yearSlider.invalidateSkinState();
			view.timelineContainer.visible = years.length>0?true:false;	
			return years;
		}
		private function handleTwitterSearch(event:FlexEvent):void {
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.TWITTER_SEARCH,model.client.shortname + " " + view.twitterSearch.text));
		}
		private function handleReload(event:MouseEvent):void {
			 var arg:Boolean;
			var type:String = event.target == view.reloadVisualization ? VisualizerEvent.TWITTER_RELOAD : VisualizerEvent.TWITTER_OPTIONS;
			if(type == VisualizerEvent.TWITTER_OPTIONS)
				arg = view.twitterOptionsBtn.selected;
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(type,arg));
		}
		private function handleSort(event:MouseEvent):void {
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.TWITTER_SORT));
		}	
		private function handleDatasetSelection(event:Event):void {
			var years:ArrayList = new ArrayList();
			var i:int;
			var dataset:Dataset;
			switch(view.visualizerArea.selectedIndex) {
				case model.CLUSTER_INDEX:
					if(view.thirdSet.selectedItem) {
						dataset = view.thirdSet.selectedItem as Dataset;
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,dataset,view.fourthSet.selectedItem,updateTimeline(dataset,view.fourthSet.selectedItem)));	
					}
				break;
				case model.MAP_INDEX:
					if(view.thirdSet.selectedItem) {
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,view.thirdSet.selectedItem,updateTimeline(view.thirdSet.selectedItem)));
					}
				break; 
				
				case model.GRAPH_INDEX:	
					if(view.firstSet.selectedItem && view.secondSet.selectedItem) {
						var ds1:Dataset = view.firstSet.selectedItem as Dataset;
						var ds2:Dataset = view.secondSet.selectedItem as Dataset;
						var ds3:Dataset = view.thirdSet.selectedItem as Dataset;
						var ds4:Dataset = view.fourthSet.selectedItem as Dataset;
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,ds1,ds2,ds3,ds4,updateTimeline(ds1,ds2,ds3,ds4)));			
					}
				break;
				
				case model.TWITTER_INDEX:
					this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,view.twitterOptions.selectedItem));	
				break;
			}
		}
		private function handleTimer(event:TimerEvent):void {
			counter++;
			
			if(counter == view.yearSlider.dataProvider.length) {
				if(view.loopBtn.selected) {
					counter = 0;
					view.yearSlider.selectedIndex = counter;
					handleYearSelection();
				}
				else {
					yearTimer.stop();
					view.playBtn.label = "Play";		
					view.playBtn.selected = false;
					this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.STOP_TIMELINE));					
				}
			} 
			else {
				view.yearSlider.selectedIndex = counter;
				handleYearSelection();
			}
		}
		private function handleYearSelection(event:IndexChangeEvent=null):void {
			var ds1:Dataset;
			var ds2:Dataset;
			var ds3:Dataset;
			var ds4:Dataset;
			ds1 = view.firstSet.selectedItem as Dataset;
			ds2 = view.secondSet.selectedItem as Dataset;
			ds3 = view.thirdSet.selectedItem as Dataset;
			ds4 = view.fourthSet.selectedItem as Dataset;
		
			var year:String = view.yearSlider.dataProvider.getItemAt(view.yearSlider.selectedIndex).year;
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.PLAY_TIMELINE,year,ds1,ds2,ds3,ds4));	
		}
		private function handlePlayButton(event:Event):void {
			counter = 0;
			if(view.playBtn.selected) {
				if(view.yearSlider.selectedIndex == view.yearSlider.dataProvider.length-1)
					view.yearSlider.selectedIndex = 0;
				
				handleYearSelection();
				yearTimer.start();
				view.playBtn.label = "Stop";
			}
			else {
				yearTimer.stop();
				view.playBtn.label = "Play";
			}					
		}
		private function handleCleanup(event:ViewEvent):void {
			this.mediatorMap.removeMediator(this);
		}
		override public function onRemove():void {
			eventMap.unmapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleIndexChanged,IndexChangedEvent);	
			
			eventMap.unmapListener(view.firstSet,IndexChangeEvent.CHANGE,handleDatasetSelection,IndexChangeEvent);
			eventMap.unmapListener(view.secondSet,IndexChangeEvent.CHANGE,handleDatasetSelection,IndexChangeEvent);
			eventMap.unmapListener(view.thirdSet,IndexChangeEvent.CHANGE,handleDatasetSelection,IndexChangeEvent);
			eventMap.unmapListener(view.fourthSet,IndexChangeEvent.CHANGE,handleDatasetSelection,IndexChangeEvent);	
			
			eventMap.unmapListener(view.yearSlider,IndexChangeEvent.CHANGE,handleYearSelection,IndexChangeEvent); 
			eventMap.unmapListener(view.playBtn,MouseEvent.CLICK,handlePlayButton,MouseEvent);
			eventMap.unmapListener(view.pdfBtn,MouseEvent.CLICK,saveImage,MouseEvent);
			eventMap.unmapListener(view,MouseEvent.CLICK,closeSettingsPanel,MouseEvent);
			
			yearTimer.removeEventListener(TimerEvent.TIMER,handleTimer);
			
			eventMap.unmapListener(eventDispatcher,ViewEvent.MENU_IMAGE_SAVE,saveImage,ViewEvent);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.CATEGORY_CHANGE,handleCategoryChange,VisualizerEvent);
			eventMap.unmapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			
			if(twitterCreated) {
				eventMap.unmapListener(view.twitterOptions,DropDownEvent.CLOSE,handleDatasetSelection,DropDownEvent);
				eventMap.unmapListener(view.twitterSearch,FlexEvent.ENTER,handleTwitterSearch,FlexEvent);
				eventMap.unmapListener(view.reloadVisualization,MouseEvent.CLICK,handleReload,MouseEvent);
				eventMap.unmapListener(view.twitterOptionsBtn,MouseEvent.CLICK,handleReload,MouseEvent);
			}
			
			trace("BottomTools Mediator Released");
			super.onRemove();
		}
	}
}