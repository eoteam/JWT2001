package com.pentagram.view.controls
{
	import flex.utils.spark.resize.ResizeHandleLines;
	import flex.utils.spark.resize.ResizeManager;
	
	import mx.core.UIComponent;
	
	import spark.components.Button;
	
	public class ResizeButton extends Button
	{
		private var resizeManager:ResizeManager;
		
		[SkinPart(required="true")]
		public var resizeHandle:UIComponent;
		
		
		public function ResizeButton() {
			super();
			mouseChildren = true; // required for the resizeHandle to accept mouse events
			minWidth = 13;
			minHeight = 13;
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName,instance);
			if(instance == resizeHandle) {
				resizeManager = new ResizeManager(this,resizeHandle,"horizontal");
				resizeManager.constrainToParentBounds = false;
			}		
		}
		
	
//		
//		override protected function updateDisplayList(w:Number, h:Number):void {
//			super.updateDisplayList(w, h);
//			
//			if (resizeHandle) {
//				resizeHandle.x = w - resizeHandle.width - 1;
//				resizeHandle.y = h - resizeHandle.height - 1;
//			}
//		}
	}
}