package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.RightTools;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Category;
	import com.pentagram.model.vo.Region;
	import com.pentagram.utils.ViewUtils;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.IndexChangedEvent;
	import mx.events.StateChangeEvent;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.GridSelectionEvent;
	
	public class RightToolsMediator extends Mediator
	{
		[Inject]
		public var view:RightTools;
		
		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher; 
		
		override public function onRegister():void
		{	
			view.visualizerArea.addEventListener(IndexChangedEvent.CHANGE,handleIndexChanged,false,0,true);
			view.categoriesPanel.continentList.addEventListener('addRegion',handleRegionSelect,false,0,true);
			view.categoriesPanel.continentList.addEventListener('removeRegion',handleRegionSelect,false,0,true);
			view.categoriesPanel.continentList.addEventListener('selectRegion',handleRegionSelect,false,0,true);
			view.optionsPanel.maxRadiusSlider.addEventListener(Event.CHANGE ,handleMaxRadius,false,0,true);
			view.optionsPanel.closeTooltipsBtn.addEventListener(MouseEvent.CLICK,handleCloseTooltips,false,0,true);
			view.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE,handleFilterToolsStateChange);
			view.categoriesPanel.check.addEventListener(MouseEvent.CLICK,check_changeHandler,false,0,true);
			view.optionsPanel.xrayToggle.addEventListener(Event.CHANGE,handleXray,false,0,true);
			
			
			view.countriesPanel.countryList.addEventListener(GridSelectionEvent.SELECTION_CHANGE,handleCountrySelection,false,0,true);
			
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
				view.optionsPanel.xrayToggle.addEventListener(Event.CHANGE,handleXray,false,0,true);
			}	
			if(view.state == "Twitter") {
				view.topics.topicsList.addEventListener(GridSelectionEvent.SELECTION_CHANGE,handleTopicsSelection,false,0,true);
			}
		}
		private function handleXray(event:Event):void {
			var alpha:Number = view.optionsPanel.xrayToggle.selected?0.2:1;
			dispatchPropEvent('alpha',alpha);
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
	}
}