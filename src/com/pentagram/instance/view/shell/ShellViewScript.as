
import com.pentagram.instance.view.visualizer.IGraphView;
import com.pentagram.instance.view.visualizer.IMapView;
import com.pentagram.instance.view.visualizer.ModuleUtil;

import flash.events.Event;

import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.events.ModuleEvent;
import mx.modules.IModuleInfo;
import mx.modules.ModuleManager;

import spark.components.Group;

public var graphView:IGraphView;
public var mapView:IMapView;
private var loaders:Array = [];
private function setInfoBtn_clickHandler(event:MouseEvent):void {
	if(setInfoBtn.selected) {
		infoPanelContainer.visible = true;
		showInfoPanelEffect.play();
	}	
	else {
		hideInfoPanelEffect.play();
	}
}
private function hideInfoPanel(event:MouseEvent):void {
	hideInfoPanelEffect.play();
	setInfoBtn.selected = false;
}
private function mainStack_changeHandler(event:IndexChangedEvent):void {
	if(mainStack.selectedIndex == 1) 
		this.clientBar.currentState = this.clientBar.editorState.name;
	else {
		this.clientBar.currentState = this.clientBar.closedState.name;		
		this.clientBar.infoBtn.selected = false;
	}
}
private function group1_creationCompleteHandler(event:FlexEvent):void {

}
private function handleGraphLoaded(event:Event):void {
	var util:ModuleUtil  = event.target as ModuleUtil;
	if(util.view is IGraphView) {
		this.graphView = util.view as IGraphView;
		this.graphHolder.addElement(util.view as Group);
	}
}
protected function visualizerArea_changeHandler(event:IndexChangedEvent):void
{
	var util:ModuleUtil;
	if(event.newIndex == 1 && mapView == null) {
		util = new ModuleUtil();
		util.addEventListener("moduleLoaded",handleMapLoaded);
		util.loadModule("com/pentagram/instance/view/visualizer/MapView.swf");	
		loaders.push(util);
	}
	else if(event.newIndex == 1 && graphView == null) {
		util = new ModuleUtil();
		util.addEventListener("moduleLoaded",handleGraphLoaded);
		util.loadModule("com/pentagram/instance/view/visualizer/GraphView.swf");
		loaders.push(util);
	}
}
private function handleMapLoaded(event:Event):void {
	var util:ModuleUtil  = event.target as ModuleUtil;
	if(util.view is IMapView) {
		this.mapView = util.view as IMapView;
		this.mapHolder.addElement(util.view as Group);
	}
}
public function unload():void {
	if(graphView)
		graphView.unload();
	if(mapView)
		mapView.unload();
}

