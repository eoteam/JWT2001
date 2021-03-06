package com.pentagram.instance.view.mediators
{
	import com.flexoop.utilities.dateutils.DateUtils;
	import com.pentagram.events.AppEvent;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.shell.Shell;
	import com.pentagram.events.ViewEvent;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.User;
	
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.events.AIREvent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.codec.PNGEncoder;
	
	import org.robotlegs.mvcs.Mediator;

	public class ViewInstanceMediator extends Mediator
	{
		[Inject]
		public var view:InstanceWindow;
		
		[Inject]
		public var model:InstanceModel;
		
		[Inject(name="ApplicationEventDispatcher")]
		public var appEventDispatcher:EventDispatcher;   
		
		private var shellLoaded:Boolean = false;
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, VisualizerEvent.CLIENT_DATA_LOADED, handleClientDataLoaded, VisualizerEvent);
			eventMap.mapListener(eventDispatcher, VisualizerEvent.LOAD_SEARCH_VIEW, loadSearchView, VisualizerEvent);
			eventMap.mapListener(eventDispatcher, ViewEvent.CLIENT_SELECTED, handleClientSelected, ViewEvent);
			eventMap.mapListener(eventDispatcher, ViewEvent.SHELL_LOADED, handleShellLoaded, ViewEvent);
			eventMap.mapListener(eventDispatcher, VisualizerEvent.TOGGLE_PROGRESS, handleProgress, VisualizerEvent);
			eventMap.mapListener(eventDispatcher, ViewEvent.START_IMAGE_SAVE, handleImageExport, ViewEvent);

			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			eventMap.mapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.mapListener(appEventDispatcher, EditorEvent.CLIENT_DELETED, handleClientDeleted, EditorEvent);
			
			eventMap.mapListener(view.nativeWindow, NativeWindowBoundsEvent.RESIZE, handleWindowResize, NativeWindowBoundsEvent);
			eventMap.mapListener(view, ViewEvent.WINDOW_FOCUS,handleWindowFocusChange, ViewEvent);

			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.INIT_INSTANCE,view.id,handleInit));
			setupWindowsMenu();
		} 
		private function handleLogin(event:AppEvent):void {
			model.user = event.args[0] as User; 
			model.exportMenuItem.enabled = model.importMenuItem.enabled = true;
			if(NativeWindow.supportsMenu)
				enableWindowsMenuItems(true);
		}
		private function setupWindowsMenu():void {
			if(NativeWindow.supportsMenu) {
				var windowMenu:NativeMenu = view.stage.nativeWindow.menu.getItemAt(0).submenu;
				var fileMenu:NativeMenu = view.stage.nativeWindow.menu.getItemAt(1).submenu;
				if(model.user)
					enableWindowsMenuItems(true);
				
				model.importMenuItem = fileMenu.items[0];
				model.exportMenuItem = fileMenu.items[1];
				model.toolBarMenuItem = windowMenu.items[2];
				model.exportImageMenuItem = windowMenu.items[3];
				
				var fullScreenMenuItem:NativeMenuItem = windowMenu.items[1];
				fullScreenMenuItem.addEventListener(Event.SELECT,handleFullScreen);
				
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
				model.exportImageMenuItem.addEventListener(Event.SELECT,handleImageExport,false,0,true);
			}
		}
		private function enableWindowsMenuItems(enabled:Boolean):void {
			var managerMenu:NativeMenu = view.stage.nativeWindow.menu.getItemAt(2).submenu;
			for each(var item:NativeMenuItem in managerMenu.items)
				item.enabled = enabled;
		}
		private function handleFullScreen(e:Event):void {
			if(view.stage.displayState == StageDisplayState.NORMAL ) {
				view.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				view.showStatusBar = false;
			} 
			else {
				view.stage.displayState = StageDisplayState.NORMAL;
				view.showStatusBar = true;
			}
		}
		private function handleLogout(event:AppEvent):void {
			model.exportMenuItem.enabled = model.importMenuItem.enabled = false;
			if(NativeWindow.supportsMenu)
				enableWindowsMenuItems(false);
		}
		private function handleClientDeleted(event:EditorEvent):void {
			var c:Client = event.args[0];
			if(c == model.client) {
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
			model.exportImageMenuItem = args[9];
			model.singletonWindowModel = args[10];
			
			view.createDeferredContent();

			eventMap.mapListener(view, AIREvent.WINDOW_ACTIVATE,handleWindowFocus, AIREvent);
			eventMap.mapListener(view, Event.CLOSE,handleCloseWindow,Event);
			
			if(NativeWindow.supportsMenu)
				view.showStatusBar = false;
			else
				view.showStatusBar = true;
			
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
			if(NativeApplication.supportsMenu) {
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
				model.exportImageMenuItem.addEventListener(Event.SELECT,handleImageExport,false,0,true);
			}
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
		private function handleImageExport(event:Event):void {
			if(view.currentState == 'visualizer') {
				view.shellView.filterTools.visible = model.includeTools;
				view.callLater(doSaveImage);
			}
		}
		private function doSaveImage():void {
			var imageSnap:BitmapData = ImageSnapshot.captureBitmapData(view.systemManager.getTopLevelRoot() as IBitmapDrawable);		
			var bmd:BitmapData = new BitmapData(imageSnap.width, imageSnap.height);
			var rect:Rectangle = new Rectangle(0,0,imageSnap.width,imageSnap.height);
			
			bmd.copyPixels(imageSnap,rect,new Point( 0, 0 ));
			imageSnap.dispose();
			var enc:PNGEncoder = new PNGEncoder();
			var imgByteArray:ByteArray = enc.encode(bmd);
			var fs:FileStream = new FileStream();
			var d:Date = new Date();
			var time:String = DateUtils.dateTimeFormat(d,"MM/DD/YY L:NN:SS A");
			time = time.split('/').join('-').split(':').join('.');
			var fl:File = model.exportDirectory.resolvePath("View Screen Shot "+time+".png");
			try{
				fs.open(fl,FileMode.WRITE); 
				fs.writeBytes(imgByteArray);
				fs.close();
			}
			catch(e:Error){	
				trace(e.message);
			}	
			Shell(view.shellView).savingPanel.visible = true;
			view.shellView.filterTools.visible = true;
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.END_IMAGE_SAVE));
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
			model.toolBarMenuItem.enabled = true;
			view.progressIndicator.visible = true;
			view.currentState = view.visualizerState.name;
			view.client = model.client;
			view.title = model.client.name;
			if(shellLoaded) {
				view.progressIndicator.visible = true;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
			}
		}
		private function handleProgress(event:VisualizerEvent):void {
			view.progressIndicator.visible = event.args[0]
		}
		private function handleShellLoaded(event:ViewEvent):void {
			if(!shellLoaded) {
				shellLoaded = true;
				view.progressIndicator.visible = true;
				eventDispatcher.dispatchEvent(new VisualizerEvent(VisualizerEvent.CLIENT_SELECTED));
			}
		}
		private function handleClientDataLoaded(event:VisualizerEvent):void {
			view.title = model.client.name;
			view.progressIndicator.visible = false;
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
			super.onRemove();
							
			eventMap.unmapListener(eventDispatcher, VisualizerEvent.CLIENT_DATA_LOADED, handleClientDataLoaded, VisualizerEvent);
			eventMap.unmapListener(eventDispatcher, VisualizerEvent.LOAD_SEARCH_VIEW, loadSearchView, VisualizerEvent);
			eventMap.unmapListener(eventDispatcher, ViewEvent.CLIENT_SELECTED, handleClientSelected, ViewEvent);
			eventMap.unmapListener(eventDispatcher, ViewEvent.SHELL_LOADED, handleShellLoaded, ViewEvent);			
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGGEDIN, handleLogin, AppEvent);
			eventMap.unmapListener(appEventDispatcher, AppEvent.LOGGEDOUT, handleLogout, AppEvent);
			eventMap.unmapListener(appEventDispatcher, EditorEvent.CLIENT_DELETED, handleClientDeleted, EditorEvent);
			eventMap.unmapListener(eventDispatcher, VisualizerEvent.TOGGLE_PROGRESS, handleProgress, VisualizerEvent);	
			eventMap.unmapListener(view.nativeWindow, NativeWindowBoundsEvent.RESIZE, handleWindowResize, NativeWindowBoundsEvent);
			eventMap.unmapListener(view, ViewEvent.WINDOW_FOCUS, handleWindowFocusChange, ViewEvent);
			eventMap.unmapListener(view, AIREvent.WINDOW_ACTIVATE,handleWindowFocus, AIREvent);
			eventMap.unmapListener(view, Event.CLOSE,handleCloseWindow,Event);
			
			if(NativeApplication.supportsMenu) {
				model.exportMenuItem.removeEventListener(Event.SELECT,handleMenuItem);
				model.importMenuItem.removeEventListener(Event.SELECT,handleImportMenuItem);
				model.toolBarMenuItem.removeEventListener(Event.SELECT,handleToggle);
				model.exportImageMenuItem.removeEventListener(Event.SELECT,handleImageExport);
			}
			
			model.clients = null;
			model.regions = null;
			model.countries = null;
			model.user = null;	
			model.colors = null;
			model.exportMenuItem = null;	
			model.importMenuItem = null;
			
			model = null;
			
			view.cleanup();
		}
		private function handleCloseWindow(event:Event):void {
			appEventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_CLOSED, view.id));
			eventDispatcher.dispatchEvent(new ViewEvent(ViewEvent.WINDOW_CLEANUP));
			view.progressIndicator.stop();
			this.mediatorMap.removeMediator(this);
		}
		private function handleWindowResize(event:NativeWindowBoundsEvent):void {
			this.dispatch(new VisualizerEvent(VisualizerEvent.WINDOW_RESIZE));
		}
	}
}