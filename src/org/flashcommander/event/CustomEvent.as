package org.flashcommander.event{

	
	import flash.events.Event;
	/**
	 * <P>Custom event class.</P>
	 * stores custom data in the <code>data</code> variable.
	 */	
	public class CustomEvent extends Event{
		
		public static const SELECT:String = "select";
		
		public var data:Object;

		public function CustomEvent(type:String, mydata:Object, bubbles:Boolean = true, cancelable:Boolean = false){
			
			super(type, bubbles,cancelable);
			
			data = mydata;
		}

	}
}