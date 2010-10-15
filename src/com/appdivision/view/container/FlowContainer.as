package com.appdivision.view.container
{
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	
	[Style(name="verticalGap", type="Number", inherit="no")]
	[Style(name="horizontalGap", type="Number", inherit="no")]
	[Style(name="horizontalAlign", type="String", enumeration="left,center,right", inherit="no")]
	[Style(name="verticalAlign", type="String", enumeration="bottom,middle,top", inherit="no")]
	
	public class FlowContainer extends Canvas
	{
		private var _direction:String;
		private var rowHeights:ArrayCollection;
		private var columnWidths:ArrayCollection;
				
		public function set direction(val:String):void{
			_direction = val;
			if(_direction == FlowContainerLayout.HORIZONTAL){
				verticalScrollPolicy = "auto";
				horizontalScrollPolicy = "off"
			}else{
				verticalScrollPolicy = "off";
				horizontalScrollPolicy = "auto"
			}
			invalidateDisplayList();
		}
		
		public function get direction():String{
			return _direction;
		}
		
		public function FlowContainer()
		{
			super();
		}
		
		private function initStyles():void{
			if(_direction == null)direction = FlowContainerLayout.HORIZONTAL;
		}
		
		override public function initialize():void{
			super.initialize();
			rowHeights = new ArrayCollection();
			columnWidths = new ArrayCollection();
			initStyles();
		}
		
		override protected function childrenCreated():void{
			super.childrenCreated();
			
			initStyles();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var tallestForRow:Number = 0;
			var rowNumber:Number = -1;	
			var widestForColumn:Number = 0;
			var columnNumber:Number = -1;
			var startIndex:int=0;
			
			for(var i:Number = 0; i < numChildren; i ++){
				var child:DisplayObject = getChildAt(i);
				if(_direction == FlowContainerLayout.HORIZONTAL){
					if(i ==0){
						child.x = child.y = 0;
						// being the first and only - this is our reigning champion
						tallestForRow = child.height;
					}else{
						var prevChild:DisplayObject = getChildAt(i - 1);
						var newWidth:Number = prevChild.width + prevChild.x + getStyle("horizontalGap");
						var newHeight:Number = prevChild.y + getStyle("verticalGap");
						if(newWidth + child.width > width){
							// align previous row
							alignRow(startIndex, i-1, prevChild.y, tallestForRow);
							startIndex=i;

							// setup new row      
							child.x = 0;
							child.y = newHeight + tallestForRow;
							// this is our reigning champion
							tallestForRow = child.height;							
						}else{
							child.x = newWidth;
							child.y = prevChild.y;
							// see whether we've got a new heavy weight champion
							if(child.height >= tallestForRow){
								tallestForRow = child.height;
							}
						}
					}
				}else{
					if(i ==0 ){
						child.x = child.y = 0;
						// being the first and only - this is our reigning champion
						widestForColumn = child.width;
					}else{
						prevChild = getChildAt(i - 1);
						newWidth = prevChild.x + getStyle("horizontalGap");
						newHeight = prevChild.height + prevChild.y + getStyle("verticalGap");
						if(newHeight + child.height > height){
							// align previous column
							alignColumn(startIndex, i-1, prevChild.x, widestForColumn);
							startIndex=i;

							// setup new column
							child.y = 0;
							child.x = newWidth + widestForColumn;
							// this is our reigning champion
							widestForColumn = child.width;
						}else{
							child.x = prevChild.x;
							child.y = newHeight;
							// see whether we've got a new heavy weight champion
							if(child.width >= widestForColumn){
								widestForColumn=child.width;
							}
						}
					}
				}
			}

			// align last thing
			if(startIndex<numChildren-1)
			{
				if(_direction == FlowContainerLayout.HORIZONTAL)
				{
					alignRow(startIndex, numChildren-1, prevChild.y, tallestForRow);
				}
				else
				{
					alignRow(startIndex, numChildren-1, prevChild.x, widestForColumn);
				}
			}

		}
		
		private function alignRow(indexFrom:int, indexTo:int, top:Number, rowHeight:Number):void
		{
			var align:String=this.getStyle('verticalAlign');
			if(align!='top')
			{
				for(var index:int=indexFrom; index<=indexTo; index++)
				{
					var child:DisplayObject=this.getChildAt(index);
					if(align=='middle')
					{
						child.y+=(rowHeight-child.height)/2;
					}
					else
					{
						child.y+=(rowHeight-child.height);
					}
				}
			}
		}
		
		private function alignColumn(indexFrom:int, indexTo:int, left:Number, columnWidth:Number):void
		{
			var align:String=this.getStyle('horizontalAlign');
			if(align!='left')
			{
				for(var index:int=indexFrom; index<=indexTo; index++)
				{
					var child:DisplayObject=this.getChildAt(index);
					if(align=='center')
					{
						child.x+=(columnWidth-child.width)/2;
					}
					else
					{
						child.x+=(columnWidth-child.width);
					}
				}
			}
		}
		
	}
}