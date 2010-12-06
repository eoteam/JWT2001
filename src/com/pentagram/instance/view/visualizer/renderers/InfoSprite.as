package com.pentagram.instance.view.visualizer.renderers
{
	import flash.display.Sprite;
	
	public class InfoSprite extends Sprite
	{
		public function InfoSprite()
		{
			super();
		}
		public var radius:int;
		public var label:String;
		public function setValues(value:int, label:String):void {
			this.radius = value;
			this.label = label;
		}
		public function drawCircle(z:Number):void {
			this.graphics.clear();
			this.graphics.beginFill(0xff0000,1);
			this.graphics.drawCircle(0,0,z);
			this.graphics.endFill();
			this.graphics.beginFill(0,1);
			this.graphics.drawCircle(0,0,0.5);
			this.graphics.endFill();
		}
	}
}