package com.pentagram.model
{
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	import com.pentagram.events.InstanceWindowEvent;
	import com.pentagram.instance.InstanceWindow;
	import com.pentagram.util.RectInterpolator;
	
	import flash.display.NativeWindowDisplayState;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Parallel;
	import mx.events.EffectEvent;
	import mx.utils.UIDUtil;
	
	import org.robotlegs.mvcs.Actor;
	
	import spark.effects.Animate;
	import spark.effects.Move;
	import spark.effects.Resize;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.interpolation.IInterpolator;
	
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
		private var tileMinimize:Boolean = true;
		public var tileMinimizeWidth:int = 200;
		public var tilePadding:Number = 8;
		public var minTilePadding:Number = 5;
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
				var availHeight:Number = Capabilities.screenResolutionY
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
						
						SimpleMotionPath(orphan.motionPaths[0]).valueTo.width = (j - (numWindows - numOrphans)) * orphanWidth;
						if(orphanCount > 0) 
							SimpleMotionPath(orphan.motionPaths[0]).valueTo.width  += gap * orphanCount;
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
			//dispatchEvent(new MDIManagerEvent(MDIManagerEvent.CASCADE, null, this, null, effectItems));
		}		
	}
}