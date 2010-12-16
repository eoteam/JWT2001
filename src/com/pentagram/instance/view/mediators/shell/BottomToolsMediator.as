package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.model.vo.Year;
	import com.pentagram.instance.view.shell.BottomToolsView;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.Region;
	import com.pentagram.utils.ViewUtils;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.IndexChangedEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	
	public class BottomToolsMediator extends Mediator
	{
		[Inject]
		public var view:BottomToolsView;
		
		[Inject]
		public var model:InstanceModel;
		
		private var yearTimer:Timer;
		private var counter:uint = 0;
		private var normalizedData:Array;
		private var maxRadius:Number = 25;
		override public function onRegister():void
		{
			view.visualizerArea.addEventListener(IndexChangedEvent.CHANGE,handleIndexChanged,false,0,true);	
			view.firstSet.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);
			view.secondSet.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);
			view.thirdSet.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);
			view.fourthSet.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);	
			view.yearSlider.addEventListener(IndexChangeEvent.CHANGE,handleYearSelection,false,0,true); 
			view.playBtn.addEventListener(MouseEvent.CLICK,handlePlayButton,false,0,true);
			
			yearTimer = new Timer(1000);
			yearTimer.addEventListener(TimerEvent.TIMER,handleTimer);
			
		}
		private function handleIndexChanged(event:IndexChangedEvent):void {
			switch(view.visualizerArea.selectedIndex) {
				case model.CLUSTER_INDEX:
					view.currentState = 'cluster';
					break;
				case model.MAP_INDEX:
					view.currentState = 'map';
					break;					
				case model.GRAPH_INDEX:
					view.currentState = 'graph';
					break;					
			}
		}
		private function handleDatasetSelection(event:Event):void {
			var years:ArrayList = new ArrayList();
			var i:int;
			var dataset:Dataset;
			switch(view.visualizerArea.selectedIndex) {
				case model.CLUSTER_INDEX:
					if(view.thirdSet.selectedItem) {
						dataset = view.thirdSet.selectedItem as Dataset;
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,dataset,view.fourthSet.selectedItem));
					}
					break;
				case model.MAP_INDEX:
					if(view.thirdSet.selectedItem) {
						dataset = view.thirdSet.selectedItem as Dataset;
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,dataset));
						
						if(dataset.time == 1) {
							view.timelineContainer.visible = true;
							
							for (i=dataset.years[0];i<=dataset.years[1];i++) {
								years.addItem(new Year(i,1)); 
							}
							view.yearSlider.dataProvider = years;
						}
						else view.timelineContainer.visible = false;
					}
					break; 
				case model.GRAPH_INDEX:	
					if(view.firstSet.selectedItem && view.secondSet.selectedItem) {
						
						var ds1:Dataset = view.firstSet.selectedItem as Dataset;
						var ds2:Dataset = view.secondSet.selectedItem as Dataset;
						var ds3:Dataset = view.thirdSet.selectedItem as Dataset;
						var ds4:Dataset = view.fourthSet.selectedItem as Dataset;
						
						var d:ArrayCollection = model.normalizeData2(ds1,ds2,ds3,ds4);	
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,d,ds1,ds2,ds3,ds4));
						
						var minYear:int = 10000; var maxYear:int; var showTime:Boolean = false;		
						if(ds1.time == 1) {
							showTime = true;
							minYear = ds1.years[0];
							maxYear = ds1.years[1];
						}
						if(ds2.time == 1) {
							showTime = true;
							if(ds2.years[0] < minYear)
								minYear = ds2.years[0];
							if(ds2.years[1] > maxYear)
								maxYear = ds2.years[1];	
						} 
						if(ds3 && ds3.time == 1) {
							showTime = true;
							if(ds3.years[0] < minYear)
								minYear = ds3.years[0];
							if(ds3.years[1] > maxYear)
								maxYear = ds3.years[1];	
						}
						if(ds4 && ds4.time ==1) {
							showTime = true;
							if(ds4.years[0] < minYear)
								minYear = ds4.years[0];
							if(ds4.years[1] > maxYear)
								maxYear = ds4.years[1];	
						}
						view.yearSlider.visible = showTime;
						if(showTime) {
							for (i=minYear;i<=maxYear;i++) {
								years.addItem(new Year(i,1));
							}
							view.yearSlider.dataProvider = years;					
						}
						
					}
					break;
			}
			
		}

		private function handleTimer(event:TimerEvent):void {
			counter++;
			
			if(counter == view.yearSlider.dataProvider.length) {
				yearTimer.stop();
				view.playBtn.label = "Play";		
				view.playBtn.selected = false;
				this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.STOP_TIMELINE));
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
		
			var year:int = view.yearSlider.dataProvider.getItemAt(view.yearSlider.selectedIndex).year as int;
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
	}
}