package com.pentagram.instance.view.visualizer.renderers
{
	import com.pentagram.model.vo.DataRow;
	
	import flash.display.Sprite;
	
	public class ClusterRenderer extends CircleRenderer
	{
		public function ClusterRenderer()
		{
			super();
			this.fillAlpha = 1;
		}
		public var radiusBeforeRendering:Number;
		public var data2:DataRow;
	}
}