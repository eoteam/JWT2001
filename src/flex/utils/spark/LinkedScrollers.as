package flex.utils.spark {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Scroller;
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 * Links two Scrollers together, keeping the vertical scroll bar positions in sync whenever this class is enabled.
	 *
	 * You can either set the two scrollers (scroller1, scroller2) directly, or you can set the scrollable components (component1, component2).
	 * The scrollable components should be any SkinnableComponent that contains a Scroller, e.g. List, TextArea.
	 * In the second case once the skin parts are added, the scroller1 and scroller2 properties will get set.
	 *
	 * This class listens for change events (user drags the scrollbar), mouse wheel events, and value_commit events (scrollbar position changes programmatically).
	 *
	 * @author Chris Callendar
	 * @date July 16th, 2010
	 */
	public class LinkedScrollers extends EventDispatcher {
		
		private var _enabled:Boolean;
		
		private var _component1:SkinnableComponent;
		
		private var _component2:SkinnableComponent;
		
		private var _scroller1:Scroller;
		
		private var _scroller2:Scroller;
		
		public function LinkedScrollers() {
			_enabled = true;
		}
		
		[Bindable("enabledChanged")]
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			if (value != _enabled) {
				_enabled = value;
				if (value) {
					// synchronize the vertical scroll positions
					updateVerticalScrollPosition(scroller1, scroller2);
				}
				dispatchEvent(new Event("enabledChanged"));
			}
		}
		
		[Bindable("component1Changed")]
		public function get component1():SkinnableComponent {
			return _component1;
		}
		
		public function set component1(value:SkinnableComponent):void {
			if (value != _component1) {
				if (_component1) {
					removePartListener(_component1);
				}
				_component1 = value;
				if (_component1) {
					addPartListener(_component1);
				}
				dispatchEvent(new Event("component1Changed"));
			}
		}
		
		[Bindable("component2Changed")]
		public function get component2():SkinnableComponent {
			return _component2;
		}
		
		public function set component2(value:SkinnableComponent):void {
			if (value != _component2) {
				if (_component2) {
					removePartListener(_component2);
				}
				_component2 = value;
				if (_component2) {
					addPartListener(_component2);
				}
				dispatchEvent(new Event("component2Changed"));
			}
		}
		
		[Bindable("scroller1Changed")]
		public function get scroller1():Scroller {
			return _scroller1;
		}
		
		public function set scroller1(value:Scroller):void {
			if (value != _scroller1) {
				if (_scroller1) {
					removeScrollListener(_scroller1, scroller1Scrolled);
				}
				_scroller1 = value;
				if (_scroller1) {
					addScrollListener(_scroller1, scroller1Scrolled);
				}
				dispatchEvent(new Event("scroller1Changed"));
			}
		}
		
		[Bindable("scroller2Changed")]
		public function get scroller2():Scroller {
			return _scroller2;
		}
		
		public function set scroller2(value:Scroller):void {
			if (value != _scroller2) {
				if (_scroller2) {
					removeScrollListener(_scroller2, scroller2Scrolled);
				}
				_scroller2 = value;
				if (_scroller2) {
					addScrollListener(_scroller2, scroller2Scrolled);
				}
				dispatchEvent(new Event("scroller2Changed"));
			}
		}
		
		
		// Listen for when the skin parts are added so that we can add listeners to the scrollbar
		private function addPartListener(skinComponent:SkinnableComponent):void {
			skinComponent.addEventListener("partAdded", partAdded);
			skinComponent.addEventListener("partRemoved", partRemoved);
			setScroller(skinComponent);
		}
		
		private function removePartListener(skinComponent:SkinnableComponent):void {
			skinComponent.removeEventListener("partAdded", partAdded);
			skinComponent.removeEventListener("partRemoved", partRemoved);
		}
		
		private function partAdded(event:Event /*spark.events.SkinPartEvent*/):void {
			if (event.hasOwnProperty("partName") && (event["partName"] == "scroller")) {
				var component:SkinnableComponent = (event.currentTarget as SkinnableComponent);
				setScroller(component);
			}
		}
		
		private function partRemoved(event:Event /*spark.events.SkinPartEvent*/):void {
			if (event.hasOwnProperty("partName") && (event["partName"] == "scroller")) {
				var component:SkinnableComponent = (event.currentTarget as SkinnableComponent);
				unsetScroller(component);
			}
		}
		
		private function setScroller(skinComponent:SkinnableComponent):void {
			if (skinComponent.hasOwnProperty("scroller") && (skinComponent["scroller"] != null)) {
				var scroller:Scroller = (skinComponent["scroller"] as Scroller);
				if (skinComponent == component1) {
					scroller1 = scroller;
				} else if (skinComponent == component2) {
					scroller2 = scroller;
				}
			}
		}
		
		private function unsetScroller(skinComponent:SkinnableComponent):void {
			if (skinComponent == component1) {
				scroller1 = null;
			} else if (skinComponent == component2) {
				scroller2 = null;
			}
		}
		
		// listen for scroll events
		private function addScrollListener(scroller:Scroller, handler:Function):void {
			scroller.addEventListener(MouseEvent.MOUSE_WHEEL, handler, false, 0, true);
			if (scroller.verticalScrollBar) {
				// the change handle handles all the user interaction events
				scroller.verticalScrollBar.addEventListener(Event.CHANGE, handler, false, 0, true);
				// the value commit is needed to handle the programmatic changes of the scroll position
				scroller.verticalScrollBar.addEventListener(FlexEvent.VALUE_COMMIT, handler, false, 0, true);
			} else {
				// add later when the scrollbar has been created
				var created:Function = function(event:FlexEvent):void {
					scroller.removeEventListener(FlexEvent.CREATION_COMPLETE, created);
					if (scroller.verticalScrollBar) {
						scroller.verticalScrollBar.addEventListener(Event.CHANGE, handler, false, 0, true);
						scroller.verticalScrollBar.addEventListener(FlexEvent.VALUE_COMMIT, handler, false, 0, true);
					}
				};
				scroller.addEventListener(FlexEvent.CREATION_COMPLETE, created, false, 0, true);
			}
		}
		
		private function removeScrollListener(scroller:Scroller, handler:Function):void {
			scroller.removeEventListener(MouseEvent.MOUSE_WHEEL, handler);
			if (scroller.verticalScrollBar) {
				scroller.verticalScrollBar.removeEventListener(Event.CHANGE, handler);
				scroller.verticalScrollBar.removeEventListener(FlexEvent.VALUE_COMMIT, handler);
			}
		}
		
		private function scroller1Scrolled(event:Event):void {
			updateVerticalScrollPosition(scroller1, scroller2);
		}
		
		private function scroller2Scrolled(event:Event):void {
			updateVerticalScrollPosition(scroller2, scroller1);
		}
		
		/**
		 * Copies the vertical scroll position from the source scroller to the target scroller.
		 */
		public function updateVerticalScrollPosition(source:Scroller, target:Scroller):void {
			if (enabled && source && source.viewport && target && target.viewport) {
				var newPos:Number = source.viewport.verticalScrollPosition;
				var oldPos:Number = target.viewport.verticalScrollPosition;
				if (newPos != oldPos) {
					target.viewport.verticalScrollPosition = newPos;
				}
			}
		}
		
	}
}