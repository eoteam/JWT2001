package com.pentagram.view.controls
{
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
	
	public class MiGList extends List
	{
		public var keyboardLookUp:Boolean = false;
		public var customProxy:Boolean = false; 
		public var includeHeader:Boolean = true;
		
		public var dragFormat:String;
		[Bindable] public var headerText:String;
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
		}


		protected function header_clickHandler(event:MouseEvent):void
		{
			sortList();
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
			}
		}                 
	}
}