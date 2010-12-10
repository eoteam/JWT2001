package com.pentagram.instance.view.mediators
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.events.VisualizerEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.editor.DatasetCreator;
	import com.pentagram.instance.view.editor.DatasetEditor;
	import com.pentagram.instance.view.editor.EditorMainView;
	import com.pentagram.instance.view.editor.OverviewEditor;
	import com.pentagram.instance.view.mediators.ViewInstanceMediator;
	import com.pentagram.instance.view.mediators.editor.DatasetCreatorMediator;
	import com.pentagram.instance.view.mediators.editor.DatasetEditorMediator;
	import com.pentagram.instance.view.mediators.editor.EditorMediator;
	import com.pentagram.instance.view.mediators.editor.OverviewEditorMediator;
	import com.pentagram.instance.view.mediators.shell.BottomBarMediator;
	import com.pentagram.instance.view.mediators.shell.SearchViewMediator;
	import com.pentagram.instance.view.mediators.shell.ShellMediator;
	import com.pentagram.instance.view.shell.BottomBarView;
	import com.pentagram.instance.view.shell.SearchView;
	import com.pentagram.instance.view.shell.ShellView;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.OpenWindowsProxy;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.User;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.main.windows.LoginWindow;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.AIREvent;
	import mx.events.FlexEvent;
	
	import org.robotlegs.mvcs.Mediator;
	import org.robotlegs.utilities.modular.mvcs.ModuleMediator;
	
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
			
			eventMap.mapListener(view.loginBtn,MouseEvent.CLICK,handleUserButton,MouseEvent,false,0,true);
			
			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.INIT_INSTANCE,view.id,handleInit));
			
			
			//mediatorMap.createMediator(view.searchView);
		} 
		private function handleLogin(event:AppEvent):void
		{
			model.user = event.args[0] as User; 
		}
		public function handleInit(...args):void {
			model.clients = args[0];
			model.regions = args[1];
			model.countries = args[2];
			model.user = args[3];	
			model.colors = args[4];
			model.exportMenuItem = args[5];	
			model.importMenuItem = args[6];	
			view.createDeferredContent();
			this.addViewListener(AIREvent.WINDOW_ACTIVATE,handleWindowFocus,AIREvent);
			this.addViewListener(Event.CLOSE,handleCloseWindow,Event);
			//eventMap.mapListener(view.gripper,MouseEvent.MOUSE_UP,handleGripperButton,MouseEvent,false,0,true);
			
			if(NativeWindow.supportsMenu) {
				
				view.showStatusBar = false;
			}
			else {
				view.showStatusBar = true;
			}
			//view.nativeWindow.addEventListener(
			
		}
		//
		private function handleWindowFocus(event:AIREvent):void {
			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_FOCUS,view.id));
		}
		private function handleClientSelected(event:ViewEvent):void {
			view.currentState = view.visualizerAndLoadingState.name;
			view.client = model.client;
			//mediatorMap.createMediator(view.shellView);
			//selectedClient = event.args[0] as Client;
		}
		private function handleShellLoaded(event:ViewEvent):void {
			eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
		}
		private function handleClientDataLoaded(event:VisualizerEvent):void {
			view.currentState = view.visualizerAndLoadedState.name;
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
			mediatorMap.removeMediatorByView(view.searchView);
			mediatorMap.removeMediatorByView(view.shellView);
			super.onRemove();
		}
		public function handleCloseWindow(event:Event):void {
			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_CLOSED, view.id));
			view.cleanup();
		}
	}
}