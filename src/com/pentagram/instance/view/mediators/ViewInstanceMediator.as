package com.pentagram.instance.view.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.editor.DatasetCreator;
	import com.pentagram.instance.view.editor.DatasetEditor;
	import com.pentagram.instance.view.editor.EditorMainView;
	import com.pentagram.instance.view.editor.OverviewEditor;
	import com.pentagram.instance.view.shell.BottomBar;
	import com.pentagram.instance.view.shell.BottomTools;
	import com.pentagram.instance.view.shell.RightTools;
	import com.pentagram.instance.view.shell.Search;
	import com.pentagram.instance.view.shell.Shell;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.User;
	
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	
	import mx.events.AIREvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ViewInstanceMediator extends Mediator
	{
		[Inject]
		public var view:InstanceWindow;
		
		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;   
		
		//private var selectedClient:Client;
		public override function onRegister():void
		{
			eventMap.mapListener( eventDispatcher, VisualizerEvent.CLIENT_DATA_LOADED, handleClientDataLoaded, VisualizerEvent);
			eventMap.mapListener( eventDispatcher, VisualizerEvent.LOAD_SEARCH_VIEW, loadSearchView, VisualizerEvent);
			eventMap.mapListener( eventDispatcher, ViewEvent.CLIENT_SELECTED, handleClientSelected, ViewEvent);
			eventMap.mapListener( eventDispatcher, ViewEvent.SHELL_LOADED, handleShellLoaded, ViewEvent);			
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent,false,0,true);
			eventMap.mapListener(appEventDispatcher, EditorEvent.CLIENT_DELETED, handleClientDeleted, EditorEvent,false,0,true);
			eventMap.mapListener(eventDispatcher, VisualizerEvent.TOGGLE_PROGRESS, handleProgress, VisualizerEvent);
			
			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.INIT_INSTANCE,view.id,handleInit));
					
			view.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE,handleWindowResize,false,0,true);

		} 
		private function handleLogin(event:AppEvent):void
		{
			model.user = event.args[0] as User; 
		}
		private function handleClientDeleted(event:EditorEvent):void {
			var c:Client = event.args[0];
			if(c == model.client) {
				model.client = null;
				view.currentState = view.searchState.name;
			}
		}
		private function handleInit(...args):void {
			model.clients = args[0];
			model.regions = args[1];
			model.countries = args[2];
			model.countryNames = args[3];
			model.user = args[4];	
			model.colors = args[5];
			model.exportMenuItem = args[6];	
			model.importMenuItem = args[7];	
			view.createDeferredContent();
			this.addViewListener(AIREvent.WINDOW_ACTIVATE,handleWindowFocus,AIREvent);
			this.addViewListener(Event.CLOSE,handleCloseWindow,Event);
			if(NativeWindow.supportsMenu) {
				
				view.showStatusBar = false;
			}
			else {
				view.showStatusBar = true;
			}
			if(view.compareArgs.length > 0) {
				model.client = view.compareArgs[0];
				model.selectedSet = view.compareArgs[1];
				model.isCompare = true;
				model.compareArgs = view.compareArgs;
				eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.CLIENT_SELECTED));
			}
		}
		private function handleWindowFocus(event:AIREvent):void {
			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_FOCUS,view.id));
		
		}
		private function handleClientSelected(event:ViewEvent):void {
			//if(!model.client.loaded)
			view.progressIndicator.visible = true;
			view.currentState = view.visualizerState.name;
			//else
			//	view.currentState = view.visualizerAndLoadedState.name;
			view.client = model.client;
			view.title = model.client.name;
			//mediatorMap.createMediator(view.shellView);
			//selectedClient = event.args[0] as Client;
			if(view.shellView)
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
		}
		private function handleProgress(event:VisualizerEvent):void {
			view.progressIndicator.visible = event.args[0]
			//view.currentState = event.args[0] == true? view.state+"AndLoading":view.state+"AndLoaded";
		}
		private function handleShellLoaded(event:ViewEvent):void {
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
		}
		private function handleClientDataLoaded(event:VisualizerEvent):void {
			//view.currentState = view.visualizerAndLoadedState.name;
			view.title = model.client.name;
		}
		private function loadSearchView(event:VisualizerEvent):void {
			view.currentState = view.searchState.name;
		}
		private function handleUserButton(event:MouseEvent):void {
			appEventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,model.LOGIN_WINDOW)); 
		}		
		private function handleGripperButton(event:MouseEvent):void {
			trace("WTFFFF");
		}
		override public function onRemove():void {
//			mediatorMap.removeMediatorByView(view.searchView);
//			mediatorMap.removeMediatorByView(view.shellView);
			model.clients = null;
			model.regions = null;
			model.countries = null;
			model.user = null;	
			model.colors = null;
			model.exportMenuItem = null;	
			model.importMenuItem = null;
			
			mediatorMap.unmapView(Search);
			mediatorMap.unmapView(BottomBar);
			mediatorMap.unmapView(Shell);  
			mediatorMap.unmapView(RightTools);
			mediatorMap.unmapView(BottomTools);
			
			mediatorMap.unmapView(EditorMainView);
			mediatorMap.unmapView(OverviewEditor);
			mediatorMap.unmapView(DatasetCreator);
			mediatorMap.unmapView(DatasetEditor);
			super.onRemove();
		}
		private function handleCloseWindow(event:Event):void {
			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_CLOSED, view.id));
			view.cleanup();
		}
		private function handleWindowResize(event:NativeWindowBoundsEvent):void {
			this.dispatch(new VisualizerEvent(VisualizerEvent.WINDOW_RESIZE));
		}
	}
}