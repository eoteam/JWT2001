package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.model.vo.Year;
	import com.pentagram.instance.view.shell.BottomTools;
	import com.pentagram.instance.view.shell.Shell;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Dataset;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.IndexChangedEvent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.codec.PNGEncoder;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	
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
		
		override public function onRegister():void
		{
			view.visualizerArea.addEventListener(IndexChangedEvent.CHANGE,handleIndexChanged,false,0,true);	
			view.firstSet.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);
			view.secondSet.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);
			view.thirdSet.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);
			view.fourthSet.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);	
			view.yearSlider.addEventListener(IndexChangeEvent.CHANGE,handleYearSelection,false,0,true); 
			view.playBtn.addEventListener(MouseEvent.CLICK,handlePlayButton,false,0,true);
			view.pdfBtn.addEventListener(MouseEvent.CLICK,saveImage,false,0,true);
			view.addEventListener(MouseEvent.CLICK,closeSettingsPanel,false,0,true);
			yearTimer = new Timer(1000);
			yearTimer.addEventListener(TimerEvent.TIMER,handleTimer);
			
			//eventMap.mapListener(eventDispatcher,ViewEvent.START_IMAGE_SAVE,handleImageSaveStart,ViewEvent);
			//eventMap.mapListener(eventDispatcher,ViewEvent.END_IMAGE_SAVE,handleImageSaveStart,ViewEvent);
			
		}
		
		
//		private function handleImageSaveStart(event:ViewEvent):void {
//			var a:int = event.type == ViewEvent.START_IMAGE_SAVE ? 0:1;
//			for each(var year:Year in  ArrayList(view.yearSlider.dataProvider).source) {
//				year.alpha = a;
//			}
//		}
		private function saveImage(event:MouseEvent):void {	
			for each(var year:Year in  ArrayList(view.yearSlider.dataProvider).source) {
				year.alpha = 0;
			}
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.START_IMAGE_SAVE));
			view.callLater(resumeImageSave);
		}
		private function resumeImageSave():void {
			view.callLater(doSaveImage);
		}
		private function doSaveImage():void {
			var imageSnap:BitmapData = ImageSnapshot.captureBitmapData(view.systemManager.getTopLevelRoot() as IBitmapDrawable);
			var pt:Point = view.parent.localToGlobal(new Point(view.x,view.y));
			
			var bmd:BitmapData = new BitmapData(imageSnap.width,(pt.y /view.parentApplication.height) * imageSnap.height);
			var rect:Rectangle = new Rectangle(0,0,imageSnap.width,(pt.y /view.parentApplication.height) * imageSnap.height);
			
			bmd.copyPixels(imageSnap,rect,new Point( 0, 0 ));
			imageSnap.dispose();
			var enc:PNGEncoder = new PNGEncoder();
			var imgByteArray:ByteArray = enc.encode(bmd);
			var fs:FileStream = new FileStream();
			var d:Date = new Date();
			var fl:File = model.exportDirectory.resolvePath("viz"+d.time+".png");
			try{
				fs.open(fl,FileMode.WRITE); 
				fs.writeBytes(imgByteArray);
				fs.close();
			}
			catch(e:Error){	
				trace(e.message);
			}	
			Shell(view.parentApplication.shellView).savingPanel.visible = true;
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.END_IMAGE_SAVE));
			for each(var year:Year in  ArrayList(view.yearSlider.dataProvider).source) {
				year.alpha = 1;
			}
		}
		private function closeSettingsPanel(event:MouseEvent):void {
			if(event.target != view.settingsBtn)
				view.settingsBtn.selected = false;
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
				case model.TWITTER_INDEX:
					view.currentState = 'twitter';
					view.twitterOptions.addEventListener(DropDownEvent.CLOSE,handleDatasetSelection,false,0,true);
					view.twitterSearch.addEventListener(FlexEvent.ENTER,handleTwitterSearch,false,0,true);
					view.reloadVisualization.addEventListener(MouseEvent.CLICK,handleReload,false,0,true);
					view.sortButton.addEventListener(MouseEvent.CLICK,handleSort,false,0,true);
				break;	
			}
		}	
		private function handleTwitterSearch(event:FlexEvent):void {
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.TWITTER_SEARCH,model.client.shortname + " " + view.twitterSearch.text));
		}
		private function handleReload(event:MouseEvent):void {
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.TWITTER_RELOAD));
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
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,dataset,view.fourthSet.selectedItem));
					}
					break;
				case model.MAP_INDEX:
					if(view.thirdSet.selectedItem) {
						dataset = view.thirdSet.selectedItem as Dataset;
					
						if(dataset.time == 1) {
							view.timelineContainer.visible = true;
							
							for (i=0;i<dataset.years.length;i++) {
								years.addItem(new Year(dataset.years[i],1)); 
							}
							view.yearSlider.dataProvider = years;
						}
						else view.timelineContainer.visible = false;
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,dataset));
					}
					break; 
				case model.GRAPH_INDEX:	
					if(view.firstSet.selectedItem && view.secondSet.selectedItem) {
						
						var ds1:Dataset = view.firstSet.selectedItem as Dataset;
						var ds2:Dataset = view.secondSet.selectedItem as Dataset;
						var ds3:Dataset = view.thirdSet.selectedItem as Dataset;
						var ds4:Dataset = view.fourthSet.selectedItem as Dataset;
						
						var minYear:int = 10000; var maxYear:int; var showTime:Boolean = false;		
						if(ds1.time == 1) {
							showTime = true;
							minYear = ds1.years[0];
							maxYear = ds1.years[ds1.years.length-1];
						}
						if(ds2.time == 1) {
							showTime = true;
							if(ds2.years[0] < minYear)
								minYear = ds2.years[0];
							if(ds2.years[1] > maxYear)
								maxYear = ds2.years[ds2.years.length-1];	
						} 
						if(ds3 && ds3.time == 1) {
							showTime = true;
							if(ds3.years[0] < minYear)
								minYear = ds3.years[0];
							if(ds3.years[1] > maxYear)
								maxYear = ds3.years[ds3.years.length-1];	
						}
						if(ds4 && ds4.time ==1) {
							showTime = true;
							if(ds4.years[0] < minYear)
								minYear = ds4.years[0];
							if(ds4.years[1] > maxYear)
								maxYear = ds4.years[ds4.years.length-1];	
						}
						view.yearSlider.visible = showTime;
						if(showTime) {
							for (i=minYear;i<=maxYear;i++) {
								years.addItem(new Year(i,1));
							}
							view.yearSlider.dataProvider = years;					
						}
						this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.DATASET_SELECTION_CHANGE,ds1,ds2,ds3,ds4));	
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
				if(view.lopBtn.selected) {
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