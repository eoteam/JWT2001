
import com.pentagram.instance.view.visualizer.IGraphView;
import com.pentagram.instance.view.visualizer.IMapView;

import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

public var graphView:IGraphView;
public  var mapView:IMapView;
private function setInfoBtn_clickHandler(event:MouseEvent):void {
	if(setInfoBtn.selected) {
		infoPanelContainer.visible = true;
		showInfoPanelEffect.play();
	}	
	else {
		hideInfoPanelEffect.play();
	}
}
private function group1_creationCompleteHandler(event:FlexEvent):void {
	
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
public function unload():void {
	if(graphView)
		graphView.unload();
	if(mapView)
		mapView.unload();
}


