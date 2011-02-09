package com.pentagram.instance.view.visualizer.views
{
	import com.greensock.TweenNano;
	import com.pentagram.instance.model.vo.Point3D;
	import com.pentagram.instance.view.visualizer.renderers.ClusterRenderer;
	import com.pentagram.instance.view.visualizer.renderers.TwitterRenderer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;

	
	public class TwitterPacking extends SpriteVisualElement
	{
		public var spriteArray:Vector.<TwitterRenderer> = new Vector.<TwitterRenderer>;
		private var circlePositions:Vector.<Point3D>;
		private var MIN_SPACE_BETWEEN_CIRCLES:uint = 2;
		public var numberList:Array = [];
		public var scaler:Number = 1;
		protected var tooltipContainer:Group;
		protected var animateCoord:Boolean = false;
		
		public function TwitterPacking(arr:Array,parent:Group)
		{
			super();			
			this.numberList = arr;
			this.tooltipContainer = parent;
		}
		public function build():void {
			var counter:uint = 0;
			while(counter < numberList.length) {
				var sprite:TwitterRenderer = new  TwitterRenderer(tooltipContainer,this);  
				sprite.data = numberList[counter];
				sprite.fillColor = 0x5599BB;
				sprite.fillAlpha = 0.2;

				sprite.textColor = 0x5599BB;
				sprite.radiusBeforeRendering = numberList[counter].count;
				sprite.scaleX= -1;
				spriteArray.push(sprite);
				this.addChild(sprite);
				counter++;
			}
			doLayout();
		}
		private var disposeCounter:int = 2;
		private var c:TwitterRenderer = null;
		private var _loc_2:Number = NaN;
		private var _loc_7:uint = 0;
		private var _loc_3:Number = 0;
		private var _loc_4:* = new Point();
		private var _loc_5:Number;
		private var timer:Timer;
		private function doLayout(animate:Boolean=false):void {
			animateCoord = animate;

			circlePositions = new Vector.<Point3D>;			
			circlePositions.push(new Point3D(0, 0, this.spriteArray[0].radiusBeforeRendering));
			circlePositions.push(new Point3D(this.spriteArray[0].radiusBeforeRendering + this.spriteArray[1].radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES, 0,this.spriteArray[1].radiusBeforeRendering));
			_loc_5 = this.circlePositions[1].x + this.circlePositions[1].z;
			
//			while (disposeCounter < this.numberList.length){
//				
//				
//			}
			timer = new Timer(50);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			timer.start();

		}
		protected function onTimer(event:TimerEvent):void {
			if(disposeCounter < this.numberList.length){
				timer.stop();
				c = this.spriteArray[disposeCounter];
				//this.graphics.moveTo(0, 0);
				_loc_2 = this.spriteArray[0].radiusBeforeRendering + c.radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES;
				_loc_3 = 2 * Math.PI * Math.random();
				_loc_7 = 0;
				while (_loc_7 < 10000) {
					
					_loc_4.x = _loc_2 * Math.cos(_loc_3);
					_loc_4.y = _loc_2 * Math.sin(_loc_3);
					_loc_2 = _loc_2 + 0.2;
					_loc_3 = _loc_3 + _loc_2 * 0.001;
					if (this.testCircleAtPoint(_loc_4, c.radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES)){
						this.circlePositions.push(new Point3D(_loc_4.x, _loc_4.y, c.radiusBeforeRendering));
						_loc_5 = Math.max(_loc_5, Math.sqrt(Math.pow(_loc_4.x, 2) + Math.pow(_loc_4.y, 2)) + c.radiusBeforeRendering);
						break;
					}
					_loc_7 = _loc_7 + 1;
				}
				//	draw(true);
				disposeCounter++;
				timer.start();
			}
			else {
				timer.stop();
				for each(var pos:Point3D in circlePositions) {
					pos.x = pos.x /_loc_5;
					pos.y = pos.y / _loc_5;
					pos.z = pos.z / _loc_5;
				}
				draw();
				animateCoord = false;
				this.dispatchEvent(new Event("layoutComplete"));
			}
		}
		protected function testCircleAtPoint(point:Point, radius:Number) : Boolean {
			var _loc_3:uint = 1;
			while (_loc_3 < this.circlePositions.length){
				
				if (Math.sqrt(Math.pow(this.circlePositions[_loc_3].x - point.x, 2) + Math.pow(this.circlePositions[_loc_3].y - point.y, 2)) < this.circlePositions[_loc_3].z + radius){
					return false;
				}
				_loc_3 = _loc_3 + 1;
			}
			return true;
		}
		
		public function draw(fast:Boolean=false) : void {			
			var c:TwitterRenderer;
			if (this.numberList.length < 2){
				return;
			}
			var _loc_2:Number = Math.floor(Math.min(width, height) * 0.5) - 3;
			var i:uint = 0;
			while (i < this.circlePositions.length){
				c = this.spriteArray[i];
				c.state = true;
				if(animateCoord) {
					c.alpha = 0;
					if(!fast)
					TweenNano.to(c,.5,{radius:this.circlePositions[i].z * _loc_2 * scaler,
						alpha:1,
						x:this.circlePositions[i].x * _loc_2 + width/2,
						y:this.circlePositions[i].y * _loc_2+ height/2});
					else {
						c.radius = this.circlePositions[i].z * _loc_2 * scaler
						c.x = this.circlePositions[i].x * _loc_2 + width/2;
						c.y = this.circlePositions[i].y * _loc_2+ height/2;
						c.alpha = 1;
						c.force();
					}
				}
				else {
					c.x =  this.circlePositions[i].x * _loc_2 + width/2;
					c.y = this.circlePositions[i].y * _loc_2+ height/2;
					if(!fast)
						TweenNano.to(c,.5,{radius:this.circlePositions[i].z * _loc_2 * scaler});
					else {
						c.radius = this.circlePositions[i].z * _loc_2 * scaler;
						c.force();
					}
				}
				i++;
			}
			cacheAsBitmap = true;
		}
		public function hide():void {
			this.includeInLayout = this.visible = animateCoord =false;
		}
		public function show():void {
			this.includeInLayout = this.visible = true;
			animateCoord = false;
		}
	}
}