package com.pentagram.instance.view.mediators.shell
{
	import com.greensock.TweenLite;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.RightTools;
	import com.pentagram.instance.view.visualizer.renderers.BaseRendererInfo;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Region;
	import com.pentagram.utils.RectInterpolator;
	import com.pentagram.utils.ViewUtils;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.effects.Parallel;
	import mx.events.IndexChangedEvent;
	import mx.events.SliderEvent;
	import mx.events.StateChangeEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.effects.interpolation.IInterpolator;
	import spark.events.GridSelectionEvent;
	
	public class RightToolsMediator extends Mediator
	{
		[Inject]
		public var view:RightTools;
		
		[Inject]
		public var model:InstanceModel;

		
		override public function onRegister():void
		{	
			eventMap.mapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleIndexChanged,IndexChangedEvent);
			
			eventMap.mapListener(view.categoriesPanel.continentList,'addRegion',handleRegionSelect,Event);
			eventMap.mapListener(view.categoriesPanel.continentList,'removeRegion',handleRegionSelect,Event);
			eventMap.mapListener(view.categoriesPanel.continentList,'selectRegion',handleRegionSelect,Event);
			eventMap.mapListener(view.categoriesPanel.check,MouseEvent.CLICK,check_changeHandler,MouseEvent);
			
			eventMap.mapListener(view.countriesPanel.countryList,GridSelectionEvent.SELECTION_CHANGE,handleCountrySelection,GridSelectionEvent);
			eventMap.mapListener(view.countriesPanel.clearSelection,MouseEvent.CLICK,handleClearSelection,MouseEvent);

			eventMap.mapListener(view.optionsPanel.maxRadiusSlider,Event.CHANGE,handleMaxRadius,Event);
			eventMap.mapListener(view.optionsPanel.closeTooltipsBtn,MouseEvent.CLICK,handleCloseTooltips,MouseEvent);
			eventMap.mapListener(view.optionsPanel.organiseTooltipsBtn,MouseEvent.CLICK,tileTooltips,MouseEvent);
			eventMap.mapListener(view.optionsPanel.xrayToggle,Event.CHANGE,handleCheck,Event);
			eventMap.mapListener(view.optionsPanel.mapToggle,Event.CHANGE,handleCheck,Event);
			eventMap.mapListener(view.optionsPanel.range,SliderEvent.CHANGE,handleRangeChange,SliderEvent);
			
			eventMap.mapListener(view,StateChangeEvent.CURRENT_STATE_CHANGE,handleFilterToolsStateChange,Event);
				
			eventMap.mapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientDataLoaded);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.DATASET_SELECTION_CHANGE,handleDatasetSelection);
			eventMap.mapListener(eventDispatcher,ViewEvent.START_IMAGE_SAVE,handleImageSaveStart,ViewEvent);
			eventMap.mapListener(eventDispatcher,ViewEvent.END_IMAGE_SAVE,handleImageSaveStart,ViewEvent);
			
			if(model.isCompare) {
				var newDP:ArrayList = new ArrayList();
				view.comparator.enabled = true;
				for each(var region:Region in  model.regions.source) {
					if(model.compareArgs[2].name != region.name) {
						region.selected = false;
						var item2:Category = new Category();
						item2.name = region.name;
						item2.color = region.color;
						item2.selected = false;
						newDP.addItem(item2);
					}
				}
				view.comparator.categoryHolder.dataProvider = newDP;
				view.categoriesPanel.check.selected = false;
			}
			for(var i:int=0;i<view.twitterLanguages.length;i++) {
				view.twitterLanguages.getItemAt(i).color = model.colors[i];
			}
			for(i=0;i<view.twitterOptions.length;i++) {
				view.twitterOptions.getItemAt(i).color = model.colors[i];
			}
		}
		private function handleClientDataLoaded(event:VisualizerEvent):void {
			view.countriesPanel.countryList.dataProvider = new ArrayCollection(model.client.countries.source);
		}
		private function handleImageSaveStart(event:ViewEvent):void {
			if(!model.includeTools)
				view.visible == false;
		}
		private function handleIndexChanged(event:IndexChangedEvent):void {
			switch(view.visualizerArea.selectedIndex) {
				case model.CLUSTER_INDEX:
					view.currentState = view.isOpen? 'openAndCluster' : 'closedAndCluster';					
					break;
				case model.MAP_INDEX:
					view.currentState = view.isOpen? 'openAndMap' : 'closedAndMap';
					view.categoriesPanel.continentList.dataProvider = model.regions;
					break;					
				case model.GRAPH_INDEX:
					view.currentState = view.isOpen? 'openAndGraph' : 'closedAndGraph';
				break;
				case model.TWITTER_INDEX:
					view.currentState = view.isOpen? 'openAndTwitter' : 'closedAndTwitter';
				break;
			}
		}
	    private function handleCountrySelection(event:GridSelectionEvent):void {
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.UPDATE_VISUALIZER_VIEW,"countrySelection",view.countriesPanel.countryList.selectedItems));
		}
		private function handleClearSelection(event:MouseEvent):void {
			view.countriesPanel.countryList.selectedIndex=-1
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.UPDATE_VISUALIZER_VIEW,"countrySelection",new Vector.<Object>()));	
		}
		private function handleRangeChange(event:SliderEvent):void {
			this.eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.UPDATE_VISUALIZER_VIEW,"rangeSelection",view.optionsPanel.range.values));
		}
		private function handleRegionSelect(event:Event):void {
			if(view.state != "twitter") {
				var item:Category = event.target.data as Category;
				view.categoriesPanel.check.selected = false;	
				var region:Category;
				var selectCount:int = 0;
				for each(region in ArrayList(view.categoriesPanel.continentList.dataProvider).source) {
					if(region.selected)
						selectCount++;
				} 
				dispatch(new VisualizerEvent(VisualizerEvent.CATEGORY_CHANGE,event.type,item,selectCount));
				switch(event.type) {
					case "addRegion":
						adjustSelection(selectCount);
					break;
					
					case "selectRegion":
						var newDP:ArrayList = new ArrayList();
						for each(var category:Category in  ArrayList(view.categoriesPanel.continentList.dataProvider).source) {
							if(category != item) {
								category.selected = false;
								var item2:Category = new Category();
								item2.name = category.name;
								item2.color = category.color;
								item2.selected = false;
								newDP.addItem(item2);
							}
						}
						view.comparator.categoryHolder.dataProvider = newDP;
						view.comparator.enabled = true;
					break;
					
					case "removeRegion":
						adjustSelection(selectCount);
					break;
				}
			}
		}
		private function adjustSelection(count:int):void {
			if(count == view.categoriesPanel.continentList.dataProvider.length) {
				view.categoriesPanel.check.selected = true;
			}
			if(count > 1) {
				view.comparator.enabled = false;
				view.comparator.currentState = "closed";
			}
		}	
		private function handleFilterToolsStateChange(event:StateChangeEvent):void {
			if(view.state == 'Graph') {
				view.optionsPanel.xrayToggle.addEventListener(Event.CHANGE,handleCheck,false,0,true);
			}	
			if(view.state == "Twitter") {
				view.topics.topicsList.addEventListener(GridSelectionEvent.SELECTION_CHANGE,handleTopicsSelection,false,0,true);
			}
		}
		private function handleCheck(event:Event):void {
			if(event.target == view.optionsPanel.xrayToggle) {
				var alpha:Number = view.optionsPanel.xrayToggle.selected?0.2:1;
				dispatchPropEvent('alpha',alpha);
			}
			else if(event.target == view.optionsPanel.mapToggle) {
				dispatchPropEvent('mapToggle',view.optionsPanel.mapToggle.selected);
			}
		}
		private function handleTopicsSelection(event:Event):void {
			dispatchPropEvent('topics',view.topics.topicsList.selectedItems);
		}
		private function handleMapToggle(event:Event):void {

		}
		private function handleMaxRadius(event:Event):void {
			model.maxRadius = view.optionsPanel.maxRadiusSlider.value;
			dispatchPropEvent('maxRadius',view.optionsPanel.maxRadiusSlider.value);
		}
		private function dispatchPropEvent(prop:String,value:*):void {
			dispatch(new VisualizerEvent(VisualizerEvent.UPDATE_VISUALIZER_VIEW,prop,value));
		}
		private function handleDatasetSelection(event:VisualizerEvent):void {
			switch(view.visualizerArea.selectedIndex) {
				case 0:
					view.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(event.args[0].optionsArray)); 
					break; 
				case 2:
					if(event.args[4])
						view.categoriesPanel.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(event.args[4].optionsArray));
				break;
				default:
					break;
			}
		}
		private function handleCloseTooltips(event:MouseEvent):void {
			for (var i:int = view.systemManager.numChildren-1;i>=0;i--){
				//trace(getQualifiedClassName(view.systemManager.getChildAt(i)));
				var child:DisplayObject = view.systemManager.getChildAt(i);
				if(getQualifiedClassName(child) == 'com.pentagram.instance.view.visualizer.renderers::RendererInfo' ||
				   getQualifiedClassName(child) == 'com.pentagram.instance.view.visualizer.renderers::TWRendererInfo'){
					view.systemManager.removeChildAt(i);
					Object(child).close();
				}
			}
		}
		private function check_changeHandler(event:Event):void {
			view.categoriesPanel.check.selected = true;
			if(view.categoriesPanel.continentList.dataProvider){
				for each(var item:Category in view.categoriesPanel.continentList.dataProvider.toArray()) {
					item.selected = true;
				}
				dispatch(new VisualizerEvent(VisualizerEvent.CATEGORY_CHANGE,"selectAll"));
				view.comparator.enabled = false;
				view.comparator.currentState = "closed";
			}
		}
		private function handleCleanup(event:ViewEvent):void {
			this.mediatorMap.removeMediator(this);
		}
		override public function onRemove():void {
			eventMap.unmapListener(view.visualizerArea,IndexChangedEvent.CHANGE,handleIndexChanged,IndexChangedEvent);
			
			eventMap.unmapListener(view.categoriesPanel.continentList,'addRegion',handleRegionSelect,Event);
			eventMap.unmapListener(view.categoriesPanel.continentList,'removeRegion',handleRegionSelect,Event);
			eventMap.unmapListener(view.categoriesPanel.continentList,'selectRegion',handleRegionSelect,Event);
			eventMap.unmapListener(view.categoriesPanel.check,MouseEvent.CLICK,check_changeHandler,MouseEvent);
			
			eventMap.unmapListener(view.countriesPanel.countryList,GridSelectionEvent.SELECTION_CHANGE,handleCountrySelection,GridSelectionEvent);
			
			eventMap.unmapListener(view.optionsPanel.maxRadiusSlider,Event.CHANGE,handleMaxRadius,Event);
			eventMap.unmapListener(view.optionsPanel.closeTooltipsBtn,MouseEvent.CLICK,handleCloseTooltips,MouseEvent);
			eventMap.unmapListener(view.optionsPanel.xrayToggle,Event.CHANGE,handleCheck,Event);
			eventMap.unmapListener(view.optionsPanel.mapToggle,Event.CHANGE,handleCheck,Event);
			eventMap.unmapListener(view.optionsPanel.range,SliderEvent.CHANGE,handleRangeChange,SliderEvent);
			
			eventMap.unmapListener(view,StateChangeEvent.CURRENT_STATE_CHANGE,handleFilterToolsStateChange,Event);
					
			eventMap.unmapListener(eventDispatcher,ViewEvent.WINDOW_CLEANUP,handleCleanup,ViewEvent);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientDataLoaded);
			eventMap.unmapListener(eventDispatcher,VisualizerEvent.DATASET_SELECTION_CHANGE,handleDatasetSelection);
			eventMap.unmapListener(eventDispatcher,ViewEvent.START_IMAGE_SAVE,handleImageSaveStart,ViewEvent);
			eventMap.unmapListener(eventDispatcher,ViewEvent.END_IMAGE_SAVE,handleImageSaveStart,ViewEvent);
			
			trace("RightTools Mediator Released");
			super.onRemove();
		}
		private function tileTooltips(event:MouseEvent):void {
			var openWinList:Array = [];
			for (var i:int = view.systemManager.numChildren-1;i>=0;i--){
				//trace(getQualifiedClassName(view.systemManager.getChildAt(i)));
				var child:DisplayObject = view.systemManager.getChildAt(i);
				if(getQualifiedClassName(child) == 'com.pentagram.instance.view.visualizer.renderers::RendererInfo' ||
					getQualifiedClassName(child) == 'com.pentagram.instance.view.visualizer.renderers::TWRendererInfo'){
					openWinList.push(child);
				}
			}
			var gap:int = 1;
			var numWindows:int = openWinList.length;
			var fillAvailableSpace:Boolean = false;
			
			var tileMinimizeWidth:int = 240; var minTilePadding:int = 2;
			if(numWindows > 1)
			{
				var sqrt:int = Math.round(Math.sqrt(numWindows));
				var numCols:int = Math.ceil(numWindows / sqrt);
				var numRows:int = Math.ceil(numWindows / numCols);
				var col:int = 0;
				var row:int = 0;
				var availWidth:Number =  view.parentDocument.width
				var availHeight:Number = view.parentDocument.height;
				var maxTiles:int = availWidth / (tileMinimizeWidth + minTilePadding);
				var targetWidth:Number = 240;//availWidth / numCols - ((gap * (numCols - 1)) / numCols);
				var targetHeight:Number = 120;//availHeight / numRows - ((gap * (numRows - 1)) / numRows);
				
				var effectItems:Array = [];
				var eff:Parallel = new Parallel();
				var interpolator:IInterpolator = new RectInterpolator();
				for(i=0; i < openWinList.length; i++)
				{	
					var win:BaseRendererInfo = openWinList[i] as BaseRendererInfo;					
					
					var rect:Rectangle = new Rectangle();
					rect.width = targetWidth;
					rect.height = targetHeight;
					
					if(i % numCols == 0 && i > 0) {
						row++;
						col = 0;
					}
					else if(i > 0)
						col++;
					rect.x = col * targetWidth;
					rect.y = row * targetHeight;			
					//pushing out by gap
					if(col > 0) 
						rect.x += gap * col;
					
					if(row > 0) 
						rect.y += gap * row;
					
					TweenLite.to(win, 0.5, {transformMatrix:{x:rect.x+10, y:rect.y+100}});
					win.pinned = false;
//					var animate:Animate = new Animate(win);
//					var path1:SimpleMotionPath = new SimpleMotionPath("x",win.x,rect.x);
//					var path2:SimpleMotionPath = new SimpleMotionPath("x",win.y,rect.y);
//					path1.interpolator = interpolator;
//					path1.interpolator = interpolator;
//					animate.motionPaths = new Vector.<MotionPath>(1);
//					animate.motionPaths[0] = path;
//					eff.addChild(animate);
//					effectItems.push(animate);
				}
			}
		}
	}
}