package com.pentagram.instance.view.visualizer.renderers
{
	import flash.display.Shape;
	import flash.geom.Point;

	public class MapRenderer extends CircleRenderer
	{
		public function MapRenderer()
		{
			super();
		}
	
		public var countrySprite:Shape;
		override protected function updateCoordinates():void {
			if(countrySprite) {
				dirtyCoordFlag = false;
				var pt:Point = countrySprite.parent.localToGlobal(new Point(countrySprite.x,countrySprite.y));
				pt = parent.globalToLocal(pt);
				x = pt.x;
				y = pt.y;
				//TweenNano.to(this,0.2,{x:pt.x,y:pt.y});	
			}
		}
		override public function set fillAlpha(value:Number):void {
			super.fillAlpha = value;
			if(value == 1)
				textColor = 0xffffffff;
		}
	}
}