package com.pentagram.view.controls
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ICollectionView;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.DragSource;
	import mx.core.FlexVersion;
	import mx.core.IFlexDisplayObject;
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	import spark.components.List;
	
	[SkinState("normal")]
	[SkinState("disabled")]
	[Event(name="sortStarted",type="flash.events.Event")]
	[Event(name="sortComplete",type="flash.events.Event")]
	[Event(name="addButtonClick",type="flash.events.Event")]
	[Event(name="removeButtonClick",type="flash.events.Event")]
	
	public class MiGList extends List
	{
		public var keyboardLookUp:Boolean = false;
		public var customProxy:Boolean = false; 
		public var includeHeader:Boolean = true;
		
		public var dragFormat:String;
		
		[Bindable] public var headerText:String;
		[Bindable] public var addLabel:String;
		[Bindable] public var removeLabel:String;
		
		public function MiGList()
		{
			super();
			this._sort = new Sort();
		}
		override protected function  keyDownHandler(event:KeyboardEvent):void {
			if(keyboardLookUp)
				super.keyDownHandler(event);
		}
		override public function addDragData(dragSource:DragSource):void {
			if(dragFormat != "" && dragFormat != null)
				dragSource.addData(this.selectedItems, dragFormat);
			super.addDragData(dragSource); 
		} 
		/**
		 * 
		 */		
		private const SORT_ASCENDING:int = 0;
		
		/**
		 * 
		 */		
		private const SORT_DESCENDING:int = 1;
		
		/**
		 * 
		 */		
		private var _sorting:int = SORT_DESCENDING;
		
		/**
		 * 
		 */		
		private var _sort:Sort;
		
		/**
		 * 
		 */		
		private var _sortField:String;
		
		/**
		 * 
		 */		
		[SkinPart(required="true")]
		public var header:Button;
		
		
		[SkinPart(required="true")]
		public var addButton:Button;
		
		
		[SkinPart(required="true")]
		public var removeButton:Button;
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get sortField():String
		{
			return this._sortField;
		}
		
		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set sortField(value:String):void
		{
			if (value == this._sortField)
				return;
			
			this._sortField = value;
		}
		

		/**
		 * 
		 * @param partName
		 * @param instance
		 * 
		 */		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			if (instance == header)
			{
				header.addEventListener(MouseEvent.CLICK, header_clickHandler);
				//header.addEventListener(ResizeEvent.RESIZE,handleButtonResize);
			}
			if(instance == addButton || instance == removeButton)
				instance.addEventListener(MouseEvent.CLICK, addremove_clickHandler);
		}
		
		/**
		 * 
		 * @param partName
		 * @param instance
		 * 
		 */		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			
			if (instance == header)
			{
				header.removeEventListener(MouseEvent.CLICK, header_clickHandler);
			}
			if(instance == addButton || instance == removeButton)
				instance.removeEventListener(MouseEvent.CLICK, addremove_clickHandler);
		}


		protected function header_clickHandler(event:MouseEvent):void
		{
			this.dispatchEvent(new Event("sortStarted"));
			sortList();
		}
		
		protected function addremove_clickHandler(event:MouseEvent):void 
		{
			this.dispatchEvent(new Event(event.target==addButton?"addButtonClick":"removeButtonClick"));	
		}
		private function sortList():void 
		{
			var dp:ICollectionView = this.dataProvider as ICollectionView;
				
			this._sort.fields = [new SortField(this._sortField)];
			
			if (dp != null)
			{
				if (this._sorting == SORT_ASCENDING)
				{
					this._sort.reverse();
					this._sorting = SORT_DESCENDING;
				}
				else
				{
					this._sorting = SORT_ASCENDING;
				}
				
				dp.sort = this._sort;
				dp.refresh();
				this.dispatchEvent(new Event("sortComplete"));
			}
		}                 
	}
}