/*
Copyright (c)2007 Frank Li
miian.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this 
software and associated documentation files (the "Software"), to deal in the Software 
without restriction, including without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to the following 
conditions:

The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package org.cove.ape {
	import flash.display.Graphics;
	
	
	public class RigidItem extends AbstractParticle{
		private var _angularVelocity:Number;
		private var _frictionalCoefficient:Number;
		private var _radian:Number;
		private var _prevRadian:Number;
		private var torque:Number;
		private var _range:Number;
		private var _mi:Number;
		
		function RigidItem(
				x:Number, 
				y:Number, 
				range:Number,
				isFixed:Boolean, 
				mass:Number=1,
				mi:Number=-1,
				elasticity:Number=0.3,
				friction:Number=0.2,
				radian:Number=0,
				angularVelocity:Number=0) {
			_range=range;
			_frictionalCoefficient=friction;
			_radian=radian;
			_angularVelocity=angularVelocity;
			torque=0;
			if(isFixed){
				mass=Number.POSITIVE_INFINITY;
				_mi=Number.POSITIVE_INFINITY;
			}else if(mi==-1){
				_mi=mass;
			}else{
				_mi=mi;
			}
			super(x,y,isFixed,mass,elasticity,0);
			setStyle(0,0xffffff,1,0x000000,1);
		}
		public override function init():void {
			cleanup();
			if (displayObject != null) {
				initDisplay();
			} else {
				drawShape(sprite.graphics);
			}
			paint();
		}
		public override function paint():void {
			sprite.x = curr.x;
			sprite.y = curr.y;
			sprite.rotation = angle;
		}	
		public function drawShape(graphics:Graphics):void{}
		public function set frictionalCoefficient(n:Number):void{
			_frictionalCoefficient=n;
		}
		public function get frictionalCoefficient():Number{
			return _frictionalCoefficient;
		}
		public function set radian(n:Number):void{
			_radian=n;
			setAxes(n);
		}
		public function get radian():Number{
			return _radian;
		}
		public function setAxes(n:Number):void{}
		public function set angularVelocity(n:Number):void{
			_angularVelocity=n;
		}
		public function get angularVelocity():Number{
			return _angularVelocity;
		}
		public function get angle():Number {
			return radian * MathUtil.ONE_EIGHTY_OVER_PI;
		}
		public function set angle(a:Number):void {
			radian = a * MathUtil.PI_OVER_ONE_EIGHTY;
		}
		public function get range():Number{
			return _range;
		}
		public function get mi():Number{
			return _mi;
		}
		public override function update(dt2:Number):void {
			//_angularVelocity*=0.99;
			//angularVelocity+=torque;
			radian+=angularVelocity*APEngine.damping;
			super.update(dt2);
			torque=0;
		}
		public function addTorque(aa:Number):void{
			//torque+=aa;
			angularVelocity+=aa;
			if(Math.abs(aa)>0.03){
				trace(">>>>>>"+angularVelocity+" "+aa);
			}
		}
		public function resolveRigidCollision(aa:Number,p):void{
			if (fixed || (! solid) || (! p.solid)) return;
			addTorque(aa);
			//_angularVelocity+=aa/10;
			//_torque=aa;
			//curr.plusEquals(fr);
		}
		public function captures(vertex:MyVector):Boolean{
			var d:Number=vertex.distance(samp)-range;
			if(d<=0){
				return true;
			}else{
				return false;
			}
		}
		public function getVelocityOn(vertex:MyVector):MyVector{
			//trace(vertex);
			var arm:MyVector=vertex.minus(samp);
			var v:MyVector=arm.normalize();
			var r:Number=angularVelocity*arm.magnitude();
			var d:MyVector=new MyVector(-v.y,v.x).multEquals(r)
			return d.plusEquals(velocity);
		}
	}
}