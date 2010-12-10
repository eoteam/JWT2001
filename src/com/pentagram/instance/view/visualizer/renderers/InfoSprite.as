package com.pentagram.instance.view.visualizer.renderers
{
	import com.pentagram.model.vo.DataRow;
	
	import flash.display.Sprite;
	
	public class InfoSprite extends Sprite
	{
		public function InfoSprite()
		{
			super();
		}
		public function set data(value:Object):void {
			radius = value.radius;
			row = value.data;
			fillColor = value.color;
		}
		public var row:DataRow;
		public var radius:Number;
		public var fillColor:uint;
		
		public function drawCircle(z:Number):void {
			this.graphics.clear();
			this.graphics.beginFill(fillColor,1);
			this.graphics.drawCircle(0,0,z);
			this.graphics.endFill();
//			this.graphics.beginFill(0,1);
//			this.graphics.drawCircle(0,0,0.5);
//			this.graphics.endFill();
		}
	}
}