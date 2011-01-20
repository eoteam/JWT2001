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
		public var particle:PhysicsParticle;
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
		override public function set x(value:Number):void {
			super.x = value;
			if(particle)
				particle.px = x;
		}
		override public function set y(value:Number):void {
			super.y = value;
			if(particle)
				particle.py = y;
		}
		override public function set radius(r:Number):void {
			super.radius = r;
			if(particle)
				particle.radius = r;
		}
	}
}