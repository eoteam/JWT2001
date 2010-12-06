package com.pentagram.view.controls
{
	import com.pentagram.main.event.ViewEvent;
	
	import org.flashcommander.components.AutoComplete;
	import org.flashcommander.event.CustomEvent;
	
	import spark.components.List;
	
	[Event(name="select", type="org.flashcommander.event.CustomEvent")]
	
	public class ListWithAutoComplete extends List
	{
		[SkinPart(required="false")]
		public var autoComplete:AutoComplete;
		private var _autoCompleteDataProvider:Array;
		private var _autoCompleteLabelField:String = "name";
		
		public function ListWithAutoComplete()
		{
			super();
		}
		public function set autoCompleteDataProvider(value:Array):void
		{
			_autoCompleteDataProvider = value;
			if(autoComplete)
				autoComplete.dataProvider = value;
		}
		public function get autoCompleteDataProvider():Array
		{
			return _autoCompleteDataProvider;
		}
		
		public function set autoCompleteLabelField(value:String):void
		{
			_autoCompleteLabelField = value;
			if(autoComplete)
				autoComplete.labelField = value;
		}
		public function get autoCompleteLabelField():String
		{
			return _autoCompleteLabelField;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == autoComplete)
			{
				autoComplete.addEventListener(CustomEvent.SELECT,handleAutoCompleteSelection);
				autoComplete.labelField = _autoCompleteLabelField;
			}
		}
		protected function handleAutoCompleteSelection(event:CustomEvent):void
		{
			autoComplete.text = '';
		}
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if (instance == autoComplete)
			{
				autoComplete.removeEventListener(CustomEvent.SELECT,handleAutoCompleteSelection);
			}
		}
	}
}