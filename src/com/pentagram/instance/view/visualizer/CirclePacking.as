package com.pentagram.instance.view.visualizer
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import com.pentagram.instance.model.vo.Point3D;
	import com.pentagram.instance.view.visualizer.renderers.InfoSprite;

	//[SWF(frameRate = '60', backgroundColor='0x000000',width='1024',height='768')]
	public class CirclePacking extends Sprite
	{
		
		private var numberList:Array= [];// = [10,10,20,30,50,10,10,10,20,30,50,10];
		private var stringList:Array= [] ;// = ["a","b","c","d","e","f","a","b","c","d","e","f"];
		private var spriteArray:Vector.<InfoSprite> = new Vector.<InfoSprite>;
		private var circlePositions:Vector.<Point3D>;
		private var MIN_SPACE_BETWEEN_CIRCLES:uint = 2;
		private var canvas:Sprite;
		public function CirclePacking()
		{
			for (var i:int=0;i<60;i++) {
				numberList.push(Math.random()*50+5);
				stringList.push(i);
			}
			build();
			dispose();
			draw();
		}
		private function build():void {
			//var c:CirclesTagCloud;	
			var counter:uint = 0;
			while(counter < numberList.length) {
				var sprite:InfoSprite = new  InfoSprite();
				sprite.setValues(numberList[counter],stringList[counter]);
				spriteArray.push(sprite);
				this.addChild(sprite);
				counter++;
			}
		}
		public function refresh():void {
			numberList = []; stringList = [];
			for (var i:int=0;i<60;i++) {
				var v:Number = Math.random()*50+5;
				numberList.push(v);
				stringList.push(i);
				spriteArray[i].setValues(v,i.toString());
			}
			dispose();
			draw();
		}
		private function dispose():void {
			var disposeCounter:int = 2;
			var _loc_1:InfoSprite = null;
			var _loc_2:Number = NaN;
			var _loc_7:uint = 0;
			var _loc_3:Number = 0;
			var _loc_4:* = new Point();
			circlePositions = new Vector.<Point3D>;			
			circlePositions.push(new Point3D(0, 0, this.spriteArray[0].radius));
			circlePositions.push(new Point3D(this.spriteArray[0].radius + this.spriteArray[1].radius + MIN_SPACE_BETWEEN_CIRCLES, 0,this.spriteArray[1].radius));
			var _loc_5:Number = this.circlePositions[1].x + this.circlePositions[1].z;
			trace(this.circlePositions[1].x , this.circlePositions[1].z);
			while (disposeCounter < this.numberList.length){

				_loc_1 = this.spriteArray[disposeCounter];
				//this.graphics.moveTo(0, 0);
				_loc_2 = this.spriteArray[0].radius + _loc_1.radius + MIN_SPACE_BETWEEN_CIRCLES;
				_loc_3 = 2 * Math.PI * Math.random();
				_loc_7 = 0;
				while (_loc_7 < 1000){
					
					_loc_4.x = _loc_2 * Math.cos(_loc_3);
					_loc_4.y = _loc_2 * Math.sin(_loc_3);
					_loc_2 = _loc_2 + 0.2;
					_loc_3 = _loc_3 + _loc_2 * 0.001;
					if (this.testCircleAtPoint(_loc_4, _loc_1.radius + MIN_SPACE_BETWEEN_CIRCLES)){
						this.circlePositions.push(new Point3D(_loc_4.x, _loc_4.y, _loc_1.radius));
						_loc_5 = Math.max(_loc_5, Math.sqrt(Math.pow(_loc_4.x, 2) + Math.pow(_loc_4.y, 2)) + _loc_1.radius);
						break;
					}
					_loc_7 = _loc_7 + 1;
				}
				disposeCounter++;
			}
			for each(var pos:Point3D in circlePositions) {
				pos.x = pos.x /_loc_5;
				pos.y = pos.y / _loc_5;
				pos.z = pos.z / _loc_5;
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
		
	 	protected function draw() : void {
			var _loc_1:InfoSprite = null;
			if (this.numberList.length < 2){
				return;
			}
			var _loc_2:* = Math.floor(Math.min(800, 600) * 0.5) - 3;
			var _loc_3:uint = 0;
			while (_loc_3 < this.circlePositions.length){
				
				_loc_1 = this.spriteArray[_loc_3];
				_loc_1.x = this.circlePositions[_loc_3].x * _loc_2;
				_loc_1.y = this.circlePositions[_loc_3].y * _loc_2;
				_loc_1.drawCircle(this.circlePositions[_loc_3].z * _loc_2);
				_loc_3 = _loc_3 + 1;
			}
			cacheAsBitmap = true;
		}		
	}
}