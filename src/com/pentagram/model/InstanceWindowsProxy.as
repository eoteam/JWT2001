package com.pentagram.model
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.utils.RectInterpolator;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Parallel;
	import mx.utils.UIDUtil;
	
	import org.robotlegs.mvcs.Actor;
	
	import spark.components.Window;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.interpolation.IInterpolator;
	
	
	public class InstanceWindowsProxy extends Actor
	{
		[Inject]
		public var appModel:AppModel;
		
		public var windowMap:IMap;
		
		public var currentWindow:InstanceWindow;
		public var exportMenuItem:NativeMenuItem;
		public var importMenuItem:NativeMenuItem;
		public var clientMenuItem:NativeMenuItem;
		//public var userMenuItem:NativeMenuItem;
		public var countriesMenuItem:NativeMenuItem;
		public var toolBarMenuItem:NativeMenuItem;
		public var exportImageMenuItem:NativeMenuItem;
		
		public const LOGIN_WINDOW:String = "loginWindow";
		public const SPREADSHEET_WINDOW:String = "spreadsheetWindow";
		public const CLIENT_WINDOW:String = "clientWindow";
		public const COUNTRIES_WINDOW:String = "countriesWindow";
		public const USERS_WINDOW:String = "userWindow";
		public const UPLOADER_WINDOW:String = "uploaderWindow";
		public const HELP_WINDOW:String = "helpWindow";
		
		private var tileMinimize:Boolean = true;
		private var tileMinimizeWidth:int = 200;
		private var tilePadding:Number = 8;
		private var minTilePadding:Number = 5;
		
		public function InstanceWindowsProxy()
		{
			windowMap = new HashMap();
		}
		public function createWindow():InstanceWindow
		{
			var instanceWindow:InstanceWindow;
			
			if (this.hasWindowUID(uid))
			{
				instanceWindow = this.getWindowFromUID(uid);
				return instanceWindow;
			}
			
			//if (!uid) {
			//	throw new Error("Class is Not Defined");
			var uid:String = UIDUtil.createUID();
			//}
			
			instanceWindow = new InstanceWindow();			
			instanceWindow.id = uid;
			this.windowMap.put(instanceWindow.id, instanceWindow);
			//dispatch(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_ADDED, uid));
			return instanceWindow;
		}
		public function getWindowFromUID(uid:String):InstanceWindow
		{
			return this.windowMap.getValue(uid) as InstanceWindow;
		}
		public function removeWindowByUID(uid:String):void
		{
			var w:InstanceWindow = windowMap.getValue(uid) as InstanceWindow;
			w.parent.removeChild(w);
			this.windowMap.remove(uid);
			w = null;
			dispatch(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_REMOVED));
			currentWindow = null;
			if(NativeWindow.supportsMenu && windowMap.size() == 0 ) {
				NativeApplication.nativeApplication.exit();
			}
		}
		public function hasWindowUID(uid:String):Boolean
		{
			return this.windowMap.containsKey(uid);
		}
		
		public function updateCollection(collection:ArrayCollection):void
		{
			var windows:Array = this.windowMap.getValues();
			var infoWindow:InstanceWindow;
			trace("currently registered:", windows);
			for each (infoWindow in windows)
			{
				if (collection.getItemIndex(infoWindow) < 0)
					collection.addItem(infoWindow);
			}
			
			for each (infoWindow in collection)
			{
				if (!this.windowMap.containsValue(infoWindow))
					collection.removeItemAt(collection.getItemIndex(infoWindow));
			}
		}
		
		public function getAllWindows():ArrayCollection
		{
			return new ArrayCollection(this.windowMap.getValues());
		}
		public function getOpenWindowList():Array
		{	
			var array:Array = [];
			var windows:Array = windowMap.getValues();
			for(var i:int = 0; i < windows.length; i++)
			{
				if(!InstanceWindow(windows[i]).nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED)
				{
					array.push(windows[i]);
				}
			}
			return array;
		}
		public function tile(fillAvailableSpace:Boolean = false,gap:Number = 0):void
		{			
			var openWinList:Array = getOpenWindowList();
			
			var numWindows:int = openWinList.length;
			
			if(numWindows == 1)
			{
				InstanceWindow(openWinList[0]).restore()
			}
			else if(numWindows > 1)
			{
				var sqrt:int = Math.round(Math.sqrt(numWindows));
				var numCols:int = Math.ceil(numWindows / sqrt);
				var numRows:int = Math.ceil(numWindows / numCols);
				var col:int = 0;
				var row:int = 0;
				var availWidth:Number =  Capabilities.screenResolutionX;
				var availHeight:Number = Capabilities.screenResolutionY;
				var maxTiles:int = availWidth / (this.tileMinimizeWidth + this.minTilePadding);
				var targetWidth:Number = availWidth / numCols - ((gap * (numCols - 1)) / numCols);
				var targetHeight:Number = availHeight / numRows - ((gap * (numRows - 1)) / numRows);
				
				var effectItems:Array = [];
				var eff:Parallel = new Parallel();
				var interpolator:IInterpolator = new RectInterpolator();
				for(var i:int = 0; i < openWinList.length; i++)
				{
					
					var win:InstanceWindow = openWinList[i] as InstanceWindow;					
					win.orderToFront();
 

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
					

					var animate:Animate = new Animate(win);
					var path:SimpleMotionPath = new SimpleMotionPath("nativeBounds",win.nativeBounds,rect);
					path.interpolator = interpolator;
					animate.motionPaths = new Vector.<MotionPath>(1);
					animate.motionPaths[0] = path;
					eff.addChild(animate);
					effectItems.push(animate);
				}
				
				
				if(col < numCols && fillAvailableSpace)
				{
					var numOrphans:int = numWindows % numCols;
					var orphanWidth:Number = availWidth / numOrphans - ((gap * (numOrphans - 1)) / numOrphans);
					//var orphanWidth:Number = availWidth / numOrphans;
					var orphanCount:int = 0
					for(var j:int = numWindows - numOrphans; j < numWindows; j++)
					{
						//var orphan:MDIWindow = openWinList[j];
						var orphan:Animate = effectItems[j] as Animate;
						
						SimpleMotionPath(orphan.motionPaths[0]).valueTo.width = orphanWidth;
						//orphan.window.width = orphanWidth;
						
						SimpleMotionPath(orphan.motionPaths[0]).valueTo.width = orphanWidth // (j - (numWindows - numOrphans)) * ;
						if(orphanCount > 0) 
							SimpleMotionPath(orphan.motionPaths[0]).valueTo.x = (gap+orphanWidth) * orphanCount	;
						orphanCount++;
					}
				} 
				eff.play();
				//dispatchEvent(new MDIManagerEvent(MDIManagerEvent.TILE, null, this, null, effectItems));
			}
		}
		public function cascade():void
		{
			var effectItems:Array = [];
			var eff:Parallel = new Parallel();
			var windows:Array = getOpenWindowList();
			var xIndex:int = 0;
			var yIndex:int = -1;
			var interpolator:IInterpolator = new RectInterpolator();
			for(var i:int = 0; i < windows.length; i++)
			{
				var win:InstanceWindow = windows[i] as InstanceWindow;
				win.orderToFront();			
				
				
				var rect:Rectangle = new Rectangle();
				rect.width = Capabilities.screenResolutionX * .5;;
				rect.height = Capabilities.screenResolutionY * .5;;
				
				if(yIndex * 40 + rect.height + 25 >= Capabilities.screenResolutionY) {
					yIndex = 0;
					xIndex++;
				}
				else
					yIndex++;
				rect.x = xIndex * 40 + yIndex * 20;
				rect.y = yIndex * 40;
				
				var animate:Animate = new Animate(win);
				var path:SimpleMotionPath = new SimpleMotionPath("nativeBounds",win.nativeBounds,rect);
				path.interpolator = interpolator;
				animate.motionPaths = new Vector.<MotionPath>(1);
				animate.motionPaths[0] = path;
				eff.addChild(animate);
				effectItems.push(animate);

			}
			eff.play();
		}			
		public	function buildMenu(window:Window=null):Array {
			
			var cmdKey:int  = NativeApplication.supportsMenu?Keyboard.COMMAND:Keyboard.CONTROL;
			
			//Arrange memu
			var arrange:NativeMenuItem = new NativeMenuItem("Arrange");
			arrange.submenu = new NativeMenu();
			
			var tile:NativeMenuItem = new NativeMenuItem("Tile");
			tile.keyEquivalent = "t";
			tile.keyEquivalentModifiers = [cmdKey];			
			tile.addEventListener(Event.SELECT,handleArrange);
			arrange.submenu.addItem(tile);
			
			var tile2:NativeMenuItem = new NativeMenuItem("Tile w Fill");
			arrange.submenu.addItem(tile2); 
			tile2.addEventListener(Event.SELECT,handleArrange);
			
			var cascade:NativeMenuItem = new NativeMenuItem("Cascade");
			arrange.submenu.addItem(cascade);
			cascade.addEventListener(Event.SELECT,handleArrange);
			
			//help
			var helpItem:NativeMenuItem = new NativeMenuItem("Help");
			//helpItem.keyEquivalent = "h";
			//helpItem.keyEquivalentModifiers = [Keyboard.COMMAND];		
			helpItem.data = [BaseWindowEvent,BaseWindowEvent.CREATE_WINDOW,HELP_WINDOW];
			helpItem.addEventListener(Event.SELECT,handleMenuItem);
			
			//Manager Menu Items
			var clients:NativeMenuItem = new NativeMenuItem("Clients");
			clients.addEventListener(Event.SELECT,handleMenuItem);
			clients.data = [BaseWindowEvent,BaseWindowEvent.CREATE_WINDOW,CLIENT_WINDOW];
			clients.enabled = false;
			
			var countries:NativeMenuItem = new NativeMenuItem("Countries");
			countries.addEventListener(Event.SELECT,handleMenuItem);
			countries.data = [BaseWindowEvent,BaseWindowEvent.CREATE_WINDOW,COUNTRIES_WINDOW];
			countries.enabled = false;
			
//			var users:NativeMenuItem = new NativeMenuItem("Users");
//			users.addEventListener(Event.SELECT,handleMenuItem);
//			users.data = [BaseWindowEvent,BaseWindowEvent.CREATE_WINDOW,USERS_WINDOW];
//			users.enabled = false;
//			
//			var uploader:NativeMenuItem = new NativeMenuItem("Uploader");
//			uploader.data = [BaseWindowEvent,BaseWindowEvent.CREATE_WINDOW,UPLOADER_WINDOW];
//			uploader.addEventListener(Event.SELECT,handleMenuItem);
			//uploader.enabled = false;
			
			//Item within Window Menu
			var newWindow:NativeMenuItem = new NativeMenuItem("New Window");	
			newWindow.keyEquivalent = "n";
			newWindow.keyEquivalentModifiers = [cmdKey];
			newWindow.data = [InstanceWindowEvent,InstanceWindowEvent.CREATE_WINDOW];
			newWindow.addEventListener(Event.SELECT,handleMenuItem);				
			
			var fullScreen:NativeMenuItem = new NativeMenuItem("Full Screen");
			fullScreen.keyEquivalent 	= "f";
			fullScreen.keyEquivalentModifiers = [cmdKey];			
			
			var toolBar:NativeMenuItem = new NativeMenuItem("Hide Tool Bars");
			toolBar.keyEquivalent = "b";
			toolBar.keyEquivalentModifiers = [cmdKey];	
			
			var exportImage:NativeMenuItem = new NativeMenuItem("Screen Capture");
			exportImage.keyEquivalent = "i";
			exportImage.keyEquivalentModifiers = [cmdKey];	
			
			//Items within File Menu
			var exp:NativeMenuItem = new NativeMenuItem("Create Spreadsheet Template File...");
			exp.data = [BaseWindowEvent,BaseWindowEvent.CREATE_WINDOW,SPREADSHEET_WINDOW];
			exp.enabled = false;
			
			var imp:NativeMenuItem = new NativeMenuItem("Import SpreadSheet...");
			imp.enabled = false;
			//imp.data = [EditorEvent,EditorEvent.START_IMPORT];

			/////////
			var windowMenu:NativeMenuItem;
			var fileMenu:NativeMenuItem;
			
			var managers:NativeMenu = new NativeMenu();
			var help:NativeMenu = new NativeMenu();
			
			if (NativeApplication.supportsMenu) {
				
				fullScreen.addEventListener(Event.SELECT,onItemSelect);
				
				var m:NativeMenu = NativeApplication.nativeApplication.menu;
				windowMenu = m.items[3] as NativeMenuItem;
				fileMenu = m.items[1] as NativeMenuItem;
				
				m.addSubmenu(managers,"Managers");
				m.addSubmenu(help,"Help");
				
				exportMenuItem = exp;
				importMenuItem  = imp;
				toolBarMenuItem = toolBar;
				exportImageMenuItem = exportImage;	
			}	
			else if(NativeWindow.supportsMenu) {
				var menu:NativeMenu = new NativeMenu();
				window.nativeWindow.menu = menu;
				windowMenu = new NativeMenuItem("Window");
				windowMenu.submenu = new NativeMenu();
				fileMenu = new NativeMenuItem("File");
				fileMenu.submenu = new NativeMenu();

				var mroot:NativeMenuItem = new NativeMenuItem("Managers");
				mroot.submenu = managers; 
				
				var hroot:NativeMenuItem = new NativeMenuItem("Help");
				hroot.submenu = help;
				
				window.stage.nativeWindow.menu.addItem(windowMenu);
				window.stage.nativeWindow.menu.addItem(fileMenu);
				window.stage.nativeWindow.menu.addItem(mroot);
				window.stage.nativeWindow.menu.addItem(hroot);
			}
			clientMenuItem = clients;
			//userMenuItem = users;
			countriesMenuItem = countries;
			
			windowMenu.submenu.addItemAt(arrange,0);
			windowMenu.submenu.addItem(fullScreen);	
			windowMenu.submenu.addItem(toolBar);
			windowMenu.submenu.addItem(exportImage);
			
			fileMenu.submenu.addItemAt(exp,0);	
			fileMenu.submenu.addItemAt(imp,0);
			fileMenu.submenu.addItemAt(newWindow,0);	
			
			managers.addItem(clients);
			managers.addItem(countries);
			//managers.addItem(users);
			//managers.addItem(uploader);
			
			help.addItem(helpItem);

			return [exp,imp,toolBar,exportImage];
		}
		private function handleArrange(event:Event):void {
			if(event.target.label == "Tile")
				tile(false,10);
			else if(event.target.label == "Tile w Fill")
				tile(true,4);
			else
				cascade();
		}
		private function onItemSelect(e:Event):void {
			if(currentWindow.stage.displayState == StageDisplayState.NORMAL ) {
				currentWindow.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				currentWindow.showStatusBar = false;
			} 
			else {
				currentWindow.stage.displayState = StageDisplayState.NORMAL;
				currentWindow.showStatusBar = true;
			}
		}
		private function handleMenuItem(event:Event):void {
			var args:Array = event.target.data as Array;
			var classRef:Class = args[0] as Class;
			eventDispatcher.dispatchEvent(new classRef(args[1],args[2]));
		}

		//		protected function handleStartUp(event:Event):void {
		//			eventDispatcher.dispatchEvent(new InstanceWindowEvent(InstanceWindowEvent.CREATE_WINDOW));
		//		}
//		private function handleExportMenu(event:Event):void {
//			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,SPREADSHEET_WINDOW));
//		}
//		private function handleImportMenu(event:Event):void {
//			eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.START_IMPORT)); 
//		}
//		private function handleClient(event:Event):void {
//			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,CLIENT_WINDOW));
//		}
//		private function handleCountries(event:Event):void {
//			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,COUNTRIES_WINDOW));
//		}
//		private function handleUsers(event:Event):void {
//			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,USERS_WINDOW));
//		}
//		private function handleUploader(event:Event):void {
//			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,UPLOADER_WINDOW));
//		}				
//		private function handleHelp(event:Event):void {
//			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.CREATE_WINDOW,HELP_WINDOW));
//		}
	}
}