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
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.mapListener(appEventDispatcher, EditorEvent.CLIENT_DELETED, handleClientDeleted, EditorEvent);
			eventMap.mapListener(eventDispatcher, VisualizerEvent.TOGGLE_PROGRESS, handleProgress, VisualizerEvent);
			
			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.INIT_INSTANCE,view.id,handleInit));
					
			view.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE,handleWindowResize,false,0,true);
			this.addViewListener(ViewEvent.WINDOW_FOCUS,handleWindowFocusChange,ViewEvent);

		} 
		private function handleLogin(event:AppEvent):void {
			model.user = event.args[0] as User; 
			model.exportMenuItem.enabled = model.importMenuItem.enabled = true;
		}
		private function handleLogout(event:AppEvent):void {
			model.exportMenuItem.enabled = model.importMenuItem.enabled = false;
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
			model.toolBarMenuItem = args[8];
			model.singletonWindowModel = args[9];
			
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
			if(model.singletonWindowModel)
				appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_FOCUS,view.id));
		}
		private function handleWindowFocus(event:AIREvent):void {
			if(model.singletonWindowModel)
				appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_FOCUS,view.id));
		
		}
		private function handleWindowFocusChange(event:ViewEvent):void {
			if(event.args[0] == true) 
				processMenuItems();
			else
				removeMenuListeners();
		}
		private function processMenuItems():void {
			
			if(view.currentState == view.visualizerState.name)  {
				model.toolBarMenuItem.enabled = true;
				
				model.toolBarMenuItem.label = view.shellView.currentState == 'fullScreen'?"Show Tool Bars":"Hide Tool Bars";
				if(model.user) {
					model.exportMenuItem.enabled = model.importMenuItem.enabled = true;
				}
			}
			else if(view.currentState == view.searchState.name) {
				model.toolBarMenuItem.label = "Hide Tool Bars";
				model.toolBarMenuItem.enabled = model.exportMenuItem.enabled = model.importMenuItem.enabled = false;
			}
			model.exportMenuItem.addEventListener(Event.SELECT,handleMenuItem,false,0,true);
			model.importMenuItem.addEventListener(Event.SELECT,handleImportMenuItem,false,0,true);
			model.toolBarMenuItem.addEventListener(Event.SELECT,handleToggle,false,0,true);
			
		}
		private function handleToggle(event:Event):void {
			if(event.target.label == "Hide Tool Bars") {
				view.shellView.currentState = "fullScreen";
				event.target.label = "Show Tool Bars";
				view.showStatusBar = false;
			}
			else {
				event.target.label = "Hide Tool Bars";
				view.shellView.currentState = model.user ? "loggedIn":"loggedOut";
				view.showStatusBar = true;
			}
		}
		private function handleMenuItem(event:Event):void {
			var args:Array = event.target.data as Array;
			var classRef:Class = args[0] as Class;
			appEventDispatcher.dispatchEvent(new classRef(args[1],args[2]));
		}
		private function handleImportMenuItem(event:Event):void {
			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.SELECT_IMPORT_FILE));
		}
		private function removeMenuListeners():void {
			model.toolBarMenuItem.removeEventListener(Event.SELECT,handleToggle);
			model.exportMenuItem.removeEventListener(Event.SELECT,handleMenuItem);
			model.importMenuItem.removeEventListener(Event.SELECT,handleImportMenuItem);	
		}
		
		
		private function handleClientSelected(event:ViewEvent):void {
			//if(!model.client.loaded)
			model.toolBarMenuItem.enabled = true;
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
			model.toolBarMenuItem.label = "Hide Tool Bars";
			model.toolBarMenuItem.enabled = model.exportMenuItem.enabled = model.importMenuItem.enabled = false;
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