package com.pentagram.model
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	
	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;
	
	import org.robotlegs.mvcs.Actor;
	
	public class InstanceWindowsProxy extends Actor
	{
		[Inject]
		public var appModel:AppModel;
		
		protected var windowMap:IMap;
		public var currentWindow:InstanceWindow;
		
		public function InstanceWindowsProxy()
		{
			windowMap = new HashMap();
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
			instanceWindow.clients = appModel.clients;
			instanceWindow.countries = appModel.countries;
			instanceWindow.continents = appModel.continents;
			
			instanceWindow.id = uid;
			this.windowMap.put(instanceWindow.id, instanceWindow);
			//dispatch(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_ADDED, uid));
			return instanceWindow;
		}
		
		/**
		 * Retrieve an <code>BaseWindow</code> by its unique identifier
		 *
		 * @param uid
		 * @return
		 *
		 */
		public function getWindowFromUID(uid:String):InstanceWindow
		{
			return this.windowMap.getValue(uid) as InstanceWindow;
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
			dispatch(new InstanceWindowEvent(InstanceWindowEvent.WINDOW_REMOVED));
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
	}
}