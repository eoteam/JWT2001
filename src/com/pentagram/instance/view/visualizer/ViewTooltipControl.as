package com.pentagram.instance.view.visualizer
{
	import flare.vis.controls.TooltipControl;
	
	import flash.display.DisplayObject;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Group;
	
	public class ViewTooltipControl extends TooltipControl
	{
		public function ViewTooltipControl(filter:*=null, tooltip:DisplayObject=null, show:Function=null, update:Function=null, hide:Function=null, delay:Number=2)
		{
			super(filter, tooltip, show, update, hide, delay);
			this.tooltip = createDefaultDataTooltip();
		}
	 	public static function createDefaultDataTooltip():DataTooltip {
			return new DataTooltip();
	
		}
		override protected function validateTipParent():void {
			var f:IVisualElementContainer
			if (tooltip.parent && remove) IVisualElementContainer(tooltip.parent).removeElement(tooltip as DataTooltip);
			
			if (tooltip.parent == null)  Group(viz.parent.parent).parentApplication.addElement(tooltip as DataTooltip);
		}
		override protected function immediateHide():void {
			tooltip.alpha = 0;
			tooltip.visible = false;
			
			if (tooltip.parent && remove)
				IVisualElementContainer(tooltip.parent).removeElement(tooltip as DataTooltip);
		}
	}
}