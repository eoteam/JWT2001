package com.pentagram.view.controls
{
	import spark.components.HGroup;
	import spark.components.SkinnableContainer;
	import mx.utils.BitFlagUtil;
	import mx.core.mx_internal;
	use namespace mx_internal;
	
	public class EditorPanel extends SkinnableContainer
	{
		
		private static const CONTROLBAR_PROPERTY_FLAG:uint = 1 << 0;
		private static const LAYOUT_PROPERTY_FLAG:uint = 1 << 1;

		public function EditorPanel()
		{
			super();
		}
		[SkinPart(required="false")]
		public var controlBarGroup:HGroup;
		
		private var controlBarGroupProperties:Object = { visible: true };
		
		public function get controlBarContent():Array
		{
			if (controlBarGroup)
				return controlBarGroup.getMXMLContent();
			else
				return controlBarGroupProperties.controlBarContent;
		}
		
		/**
		 *  @private
		 */
		public function set controlBarContent(value:Array):void
		{
			if (controlBarGroup)
			{
				controlBarGroup.mxmlContent = value;
				controlBarGroupProperties = BitFlagUtil.update(controlBarGroupProperties as uint, 
					CONTROLBAR_PROPERTY_FLAG, value != null);
			}
			else
				controlBarGroupProperties.controlBarContent = value;
			
			invalidateSkinState();
		}
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance)
			

			if (instance == controlBarGroup)
			{
				// copy proxied values from controlBarGroupProperties (if set) to contentGroup
				var newControlBarGroupProperties:uint = 0;
				
				if (controlBarGroupProperties.controlBarContent !== undefined)
				{
					controlBarGroup.mxmlContent = controlBarGroupProperties.controlBarContent;
					newControlBarGroupProperties = BitFlagUtil.update(newControlBarGroupProperties, 
						CONTROLBAR_PROPERTY_FLAG, true);
				}
				controlBarGroupProperties = newControlBarGroupProperties;
			}
		}	
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == controlBarGroup)
			{
				// copy proxied values from contentGroup (if explicitely set) to contentGroupProperties
				
				var newControlBarGroupProperties:Object = {};
				
				if (BitFlagUtil.isSet(controlBarGroupProperties as uint, CONTROLBAR_PROPERTY_FLAG))
					newControlBarGroupProperties.controlBarContent = controlBarGroup.getMXMLContent();
				controlBarGroupProperties = newControlBarGroupProperties;
				
				controlBarGroup.mxmlContent = null;
			}
		}
	}
}