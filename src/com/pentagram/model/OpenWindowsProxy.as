package com.pentagram.model
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.main.windows.BaseWindow;
	import com.pentagram.utils.ViewUtils;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Actor;
	
	/**
	 * Proxy to keep track of current open <code>BaseWindow</code> objects
	 * @author joel
	 *
	 */
	public class OpenWindowsProxy extends Actor
	{
		
		public const LOGIN_WINDOW:String = "loginWindow";
		public const SPREADSHEET_WINDOW:String = "spreadsheetWindow";
		public const CLIENT_WINDOW:String = "clientWindow";
		public const COUNTRIES_WINDOW:String = "countriesWindow";
		public const USERS_WINDOW:String = "userWindow";
		public const UPLOADER_WINDOW:String = "uploaderWindow";
		public const HELP_WINDOW:String = "helpWindow";
		public const LANDING_WINDOW:String = "landingWindow";
		/**
		 * Hash of currently open windows
		 */
		protected var windowMap:IMap;
		protected var viewsMap:IMap;
		
		public function OpenWindowsProxy()
		{
			windowMap = new HashMap();
			viewsMap = new HashMap();
			viewsMap.put(LOGIN_WINDOW,"com.pentagram.main.windows.LoginWindow");
			viewsMap.put(SPREADSHEET_WINDOW,"com.pentagram.main.windows.ExportSpreadSheetWindow");
			viewsMap.put(CLIENT_WINDOW,"com.pentagram.main.windows.ClientsWindow");
			viewsMap.put(COUNTRIES_WINDOW,"com.pentagram.main.windows.CountriesWindow");
			viewsMap.put(UPLOADER_WINDOW,"com.pentagram.main.windows.BatchUploader");
			viewsMap.put(HELP_WINDOW,"com.pentagram.main.windows.HelpWindow");
			viewsMap.put(LANDING_WINDOW,"com.pentagram.main.windows.LandingWindow");
		}
		
		/**
		 * Create a new <code>BaseWindow</code>. If the <code>windowMap</code>
		 * already contains a window with the specified UID, return that window
		 * instead
		 *
		 * @param uid identifies the window
		 * @return
		 *
		 */
		public function createWindow(uid:String = null):BaseWindow
		{
			var infoWindow:BaseWindow;
			
			if (this.hasWindowUID(uid))
			{
				infoWindow = this.getWindowFromUID(uid);
				return infoWindow
			}
			
			if (!uid) {
				throw new Error("Class is Not Defined");
				//uid = UIDUtil.createUID();
			}
			infoWindow = ViewUtils.instantiateClass(viewsMap.getValue(uid));
			infoWindow.id = uid;
			this.windowMap.put(infoWindow.id, infoWindow);
			dispatch(new BaseWindowEvent(BaseWindowEvent.WINDOW_ADDED, uid));
			return infoWindow;
		}
		
		/**
		 * Retrieve an <code>BaseWindow</code> by its unique identifier
		 *
		 * @param uid
		 * @return
		 *
		 */
		public function getWindowFromUID(uid:String):BaseWindow
		{
			return this.windowMap.getValue(uid) as BaseWindow;
		}
		
		/**
		 * Remove a <code>BaseWindow</code> from the <code>windowMap</code>
		 * by its unique identifier.
		 *
		 * @param uid
		 *
		 */
		public function removeWindowByUID(uid:String):void
		{
			this.windowMap.remove(uid);
			dispatch(new BaseWindowEvent(BaseWindowEvent.WINDOW_REMOVED, uid));
		}
		
		/**
		 * Check if the <code>windowMap</code> contains an <code>BaseWindow</code>
		 * unique identifier as a key.
		 *
		 * @param uid
		 * @return
		 *
		 */
		public function hasWindowUID(uid:String):Boolean
		{
			return this.windowMap.containsKey(uid);
		}
		
		public function updateCollection(collection:ArrayCollection):void
		{
			var windows:Array = this.windowMap.getValues();
			var infoWindow:BaseWindow;
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
	}
}