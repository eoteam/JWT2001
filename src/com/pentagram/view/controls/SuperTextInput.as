package com.pentagram.view.controls {
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;

	[Event(name="clear", type="flash.events.Event")]
	public class SuperTextInput extends TextInput {

		[SkinPart(required="false")]
		public var clearButton:Button;

		private var _prompt:String = '';
		private var _focused:Boolean = false;

		public function SuperTextInput() {
			super();
			
			//watch for programmatic changes to text property
			this.addEventListener(FlexEvent.VALUE_COMMIT, textChangedHandler, false, 0, true);
			
			//watch for user changes (aka typing) to text property
			this.addEventListener(TextOperationEvent.CHANGE, textChangedHandler, false, 0, true);
		}


		private function textChangedHandler(e:Event):void {
			if (clearButton) {
				clearButton.visible = (text.length > 0);
			}
			invalidateSkinState();
		}

		private function clearClick(e:MouseEvent):void {
			text = '';
			dispatchEvent(new Event("clear"));
		}

		override protected function focusInHandler(event:FocusEvent):void {
			super.focusInHandler(event);
			_focused = true;
			invalidateSkinState();
		}
		override protected function focusOutHandler(event:FocusEvent):void {
			super.focusOutHandler(event);
			_focused = false;
			invalidateSkinState();
		}

		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			if (instance == promptDisplay) {
				promptDisplay.text = prompt;
			} else if (instance == clearButton) {
				clearButton.addEventListener(MouseEvent.CLICK, clearClick);
				clearButton.visible = (text != null && text.length > 0);
			}
		}

		override protected function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			if (instance == clearButton) {
				clearButton.removeEventListener(MouseEvent.CLICK, clearClick);
			}
		}

		override protected function getCurrentSkinState():String {
			if (prompt.length > 0 && text.length == 0 && !_focused) {
				return 'normalWithPrompt';
			}
			return super.getCurrentSkinState();
		}
	}
}