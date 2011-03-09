
import com.pentagram.instance.view.visualizer.interfaces.IClusterView;
import com.pentagram.instance.view.visualizer.interfaces.IGraphView;
import com.pentagram.instance.view.visualizer.interfaces.IMapView;
import com.pentagram.instance.view.visualizer.interfaces.ITwitterView;
import com.pentagram.instance.view.visualizer.interfaces.IVisualizer;

import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

public var graphView:IGraphView;
public var mapView:IMapView;
public var clusterView:IClusterView;
public var twitterView:ITwitterView;

private var infoOpen:Boolean = false;
private function setInfoBtn_clickHandler(event:MouseEvent):void {
	if(!infoOpen) {
		infoPanelContainer.visible = true;
		showInfoPanelEffect.play();
		infoOpen = true;
	}	
	else {
		hideInfoPanelEffect.play();
		infoOpen = false;
	}
}
private function group1_creationCompleteHandler(event:FlexEvent):void {
	
}
private function hideInfoPanel(event:MouseEvent):void {
	hideInfoPanelEffect.play();
	infoOpen = false;
}
private function mainStack_changeHandler(event:IndexChangedEvent):void {
	if(mainStack.selectedIndex == 1) 
		this.clientBar.currentState = this.clientBar.editorState.name;
	else {
		this.clientBar.currentState = this.clientBar.closedState.name;		
		this.clientBar.infoBtn.selected = false;
	}
}
public function get currentVisualizer():IVisualizer {
	
	return NavigatorContent(visualizerArea.selectedChild).getElementAt(0) as IVisualizer;

}
protected function group1_clickHandler(event:MouseEvent):void
{
	if(event.target != tools.settingsBtn) {
		if(event.target is DisplayObject && exportPanel.contains(DisplayObject(event.target)))
			return;
		tools.settingsBtn.selected = false;
	}
	if(event.target != bottomBarView.loginBtn) {
		if(event.target is DisplayObject && loginPanel.contains(DisplayObject(event.target)))
			return;
		bottomBarView.loginBtn.selected = false;					
	}
}

