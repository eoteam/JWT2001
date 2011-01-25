package com.pentagram.instance.view.mediators.shell
{
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.RightTools;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Category;
	import com.pentagram.utils.ViewUtils;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayList;
	import mx.events.IndexChangedEvent;
	import mx.events.StateChangeEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class RightToolsMediator extends Mediator
	{
		[Inject]
		public var view:RightTools;
		
		[Inject]
		public var model:InstanceModel;
		
		override public function onRegister():void
		{	
			view.visualizerArea.addEventListener(IndexChangedEvent.CHANGE,handleIndexChanged,false,0,true);
			view.continentList.addEventListener('addRegion',handleRegionSelect,false,0,true);
			view.continentList.addEventListener('removeRegion',handleRegionSelect,false,0,true);
			view.continentList.addEventListener('selectRegion',handleRegionSelect,false,0,true);
			view.maxRadiusSlider.addEventListener(Event.CHANGE ,handleMaxRadius,false,0,true);
			view.closeTooltipsBtn.addEventListener(MouseEvent.CLICK,handleCloseTooltips,false,0,true);
			view.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE,handleFilterToolsStateChange);
			view.check.addEventListener(MouseEvent.CLICK,check_changeHandler,false,0,true);
			view.xrayToggle.addEventListener(Event.CHANGE,handleXray,false,0,true);
			
			eventMap.mapListener(eventDispatcher,VisualizerEvent.DATASET_SELECTION_CHANGE,handleDatasetSelection);
			eventMap.mapListener(eventDispatcher,ViewEvent.START_IMAGE_SAVE,handleImageSaveStart,ViewEvent);
			eventMap.mapListener(eventDispatcher,ViewEvent.END_IMAGE_SAVE,handleImageSaveStart,ViewEvent);
			
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
					view.continentList.dataProvider = model.regions;
					break;					
				case model.GRAPH_INDEX:
					view.currentState = view.isOpen? 'openAndGraph' : 'closedAndGraph';
					break;					
			}
		}

		private function handleRegionSelect(event:Event):void {
			var item:Category = view.continentList.selectedItem as Category;
			view.check.selected = false;	
			dispatch(new VisualizerEvent(VisualizerEvent.CATEGORY_CHANGE,event.type,item));
			switch(event.type) {
				case "addRegion":
					adjustSelection();
				break;
				
				case "selectRegion":
					for each(var category:Category in  ArrayList(view.continentList.dataProvider).source) {
						if(category != item)
							category.selected = false;
					}
				break;
				
				case "removeRegion":
					adjustSelection();
				break;
			}
		}
		private function adjustSelection():void {
			var region:Category;
			var selectCount:int = 0;
			for each(region in ArrayList(view.continentList.dataProvider).source) {
				if(region.selected)
					selectCount++;
			} 
			switch(selectCount) {
				case selectCount >= 4:
					for each(region in ArrayList(view.continentList.dataProvider).source) {
					region.enabled = true;
					region.selected = true;
				}
					break;
				case selectCount > 1:
					for each(region in ArrayList(view.continentList.dataProvider).source) {
					if(region.selected)
						region.enabled = true;
				}
					break;
				case selectCount == 1:
					for each(region in ArrayList(view.continentList.dataProvider).source) {
					if(region.selected)
						region.enabled = false;
					else
						region.enabled = true;
				}
					break;
			}
		}	
		private function handleFilterToolsStateChange(event:StateChangeEvent):void {
//			if(view.state == 'Map') {		
//				
//				view.mapToggle.addEventListener(Event.CHANGE,handleMapToggle,false,0,true);
//			}
//			else
			if(view.state == 'Graph') {
				view.xrayToggle.addEventListener(Event.CHANGE,handleXray,false,0,true);
			}	
		}
		private function handleXray(event:Event):void {
			var alpha:Number = view.xrayToggle.selected?0.2:1;
			dispatchPropEvent('alpha',alpha);
		}
		private function handleMapToggle(event:Event):void {
			///dispatchPropEvent('mapToggle',view.mapToggle.selected);
//			if(view.visualizerArea.selectedIndex == 1) {
//				IMapView(view.currentVisualizer).toggleMap();
//			}
		}
		private function handleMaxRadius(event:Event):void {
			model.maxRadius = view.maxRadiusSlider.value;
			dispatchPropEvent('maxRadius',view.maxRadiusSlider.value);
			//view.currentVisualizer.updateMaxRadius();
		}
		private function dispatchPropEvent(prop:String,value:*):void {
			dispatch(new VisualizerEvent(VisualizerEvent.UPDATE_VISUALIZER_VIEW,prop,value));
		}
		private function handleDatasetSelection(event:VisualizerEvent):void {
			switch(view.visualizerArea.selectedIndex) {
				case 0:
					view.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(event.args[0].optionsArray)); 
					break; 
				case 2:
					if(event.args[4])
						view.continentList.dataProvider = new ArrayList(ViewUtils.vectorToArray(event.args[4].optionsArray));
				break;
				default:
					break;
			}
		}
		private function handleCloseTooltips(event:MouseEvent):void {
//			while(FlexGlobals.topLevelApplication.systemManager.popUpChildren.numChildren > 0){   
//				PopUpManager.removePopUp(Popup(systemManager.popUpChildren.getChildAt(0))); this
//			}
			// if you scope your popups to other than PopUpManagerChildList.POPUP
			// you need to scan this and check the class name to decide if you need to remove the child
			for (var i:int = view.systemManager.numChildren-1;i>=0;i--){
				trace(getQualifiedClassName(view.systemManager.getChildAt(i)));
				if(getQualifiedClassName(view.systemManager.getChildAt(i))=='com.pentagram.instance.view.visualizer.renderers::RendererInfo'){
					view.systemManager.removeChildAt(i);
				}
			}
		}
		private function check_changeHandler(event:Event):void
		{
			view.check.selected = true;
			for each(var item:Category in view.continentList.dataProvider.toArray()) {
				item.selected = true;
			}
			dispatch(new VisualizerEvent(VisualizerEvent.CATEGORY_CHANGE,"selectAll"));
		}

	}
}