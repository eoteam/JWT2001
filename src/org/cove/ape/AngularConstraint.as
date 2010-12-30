/*
Copyright (c) 2006, 2007 Alec Cove

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

/*
TODO:
*/

// This class contributed by Jim Bonacci - www.totaljerkface.com
package org.cove.ape {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * An Angular Constraint between 3 particles
	 */
	public class AngularConstraint extends AbstractConstraint{
		
		private static const PI2 = Math.PI * 2;
		
		private var _p1:AbstractParticle;
		private var _p2:AbstractParticle;
		private var _p3:AbstractParticle;
		
		private var _minAng:Number;
		private var _maxAng:Number;
		private var _minBreakAng:Number;
		private var _maxBreakAng:Number;
	
		private var _restLength:Number;
		
		private var _broken:Boolean;
		
		public function AngularConstraint(
				p1:AbstractParticle, 
				p2:AbstractParticle,
				p3:AbstractParticle,
				minAng:Number,
				maxAng:Number,
				minBreakAng:Number = -10,
				maxBreakAng:Number = 10,
				stiffness:Number = .5) {
			
			super(stiffness);
			
			this.p1 = p1;
			this.p2 = p2;
			this.p3 = p3;
			checkParticlesLocation();
			
			if (minAng == 10) {
				this.minAng = acRadian;
				this.maxAng = acRadian;
			} else {
				this.minAng = minAng;
				this.maxAng = maxAng;
			}
			this.minBreakAng = minBreakAng;
			this.maxBreakAng = maxBreakAng;
			
			_restLength = currLength;
		}
		
		
		public function get p1():AbstractParticle{
			return _p1;
		}
		
		
		public function set p1(p:AbstractParticle){
			_p1 = p;
		}
		
		
		public function get p2():AbstractParticle{
			return _p2;
		}
		
		
		public function set p2(p:AbstractParticle){
			_p2 = p;
		}
		
		
		public function get p3():AbstractParticle{
			return _p3;
		}
		
		
		public function set p3(p:AbstractParticle){
			_p3 = p;
		}
		
		
		/**
		 * The rotational value created by the positions of the first two particles attached to this
		 * AngularConstraint. You can use this property to in your own painting methods, along with the 
		 * <code>center</code> property. 
		 * 
		 * @returns A Number representing the rotation of p1 and p2 of this AngularConstraint in radians
		 */			
		public function get radian():Number {
			var d:Vector = delta;
			return Math.atan2(d.y, d.x);
		}
		
		
		/**
		 * The rotational value created by the positions of the first two particles attached to this
		 * AngularConstraint. You can use this property to in your own painting methods, along with the 
		 * <code>center</code> property. 
		 * 
		 * @returns A Number representing the rotation of p1 and p2 of this AngularConstraint in degrees
		 */					
		public function get angle():Number {
			return radian * MathUtil.ONE_EIGHTY_OVER_PI;
		}
		
				
		/**
		 * The center position created by the relative positions of the first two particles attached to this
		 * AngularConstraint. You can use this property to in your own painting methods, along with the 
		 * rotation property.
		 * 
		 * @returns A Vector representing the center of p1 and p2 of this AngularConstraint
		 */			
		public function get center():Vector {
			return (p1.curr.plus(p2.curr)).divEquals(2);
		}
		
		
		/**
		 * The current difference between the angle of p1, p2, and p3 and a straight line (pi)
		 * 
		 */	
		public function get acRadian():Number {
			var ang12:Number = Math.atan2(p2.curr.y - p1.curr.y, p2.curr.x - p1.curr.x);
			var ang23:Number = Math.atan2(p3.curr.y - p2.curr.y, p3.curr.x - p2.curr.x);
			
			var angDiff:Number = ang12 - ang23;
			return angDiff;
		}
		
		
		/**
		 * Returns the distance between its first two 
		 * attached particles.
		 */ 
		public function get currLength():Number {
			return p1.curr.distance(p2.curr);
		}		
			
		/**
		 * The <code>restLength</code> property sets the length of AngularConstraint. This value will be
		 * the distance between the two particles unless their position is altered by external forces. 
		 * The AngularConstraint will always try to keep the particles this distance apart. Values must 
		 * be > 0.
		 */			
		public function get restLength():Number {
			return _restLength;
		}
		
		
		/**
		 * @private
		 */	
		public function set restLength(r:Number):void {
			if (r <= 0) throw new ArgumentError("restLength must be greater than 0");
			_restLength = r;
		}
		
		
		/**
		 * Returns true if the passed particle is one of the two particles attached to this AngularConstraint.
		 */		
		public function isConnectedTo(p:AbstractParticle):Boolean {
			return (p == p1 || p == p2 || p == p3);
		}
		
		
		/**
		 * Returns true if both connected particle's <code>fixed</code> property is true.
		 */
		public function get fixed():Boolean {
			return (p1.fixed && p2.fixed && p3.fixed);
		}
		
		
		public function get minAng():Number {
			return _minAng;
		}
		
		
		public function set minAng(n:Number):void {
			_minAng = n;
		}
		
		
		public function get maxAng():Number {
			return _maxAng;
		}
		
		
		public function set maxAng(n:Number):void {
			_maxAng = n;
		}
		
		
		public function get minBreakAng():Number {
			return _minBreakAng;
		}
		
		
		public function set minBreakAng(n:Number):void {
			_minBreakAng = n;
		}
		
		
		public function get maxBreakAng():Number {
			return _maxBreakAng;
		}
		
		
		public function set maxBreakAng(n:Number):void{
			_maxBreakAng = n;
		}
		
		
		public function get broken():Boolean {
			return _broken;
		}
		
		
		public function set broken(b:Boolean):void{
			_broken = b;
		}
		
		
		/**
		 * Sets up the visual representation of this AngularConstraint. This method is called 
		 * automatically when an instance of this AngularConstraint's parent Group is added to 
		 * the APEngine, when  this AngularConstraint's Composite is added to a Group, or this 
		 * AngularConstraint is added to a Composite or Group.
		 */			
		public override function init():void {	
			cleanup();
			if (displayObject != null) {
				initDisplay();
			}
			paint();
		}
		
				
		/**
		 * The default painting method for this constraint. This method is called automatically
		 * by the <code>APEngine.paint()</code> method. If you want to define your own custom painting
		 * method, then create a subclass of this class and override <code>paint()</code>.
		 */			
		public override function paint():void {
			
			if (displayObject != null) {
				var c:Vector = center;
				sprite.x = c.x; 
				sprite.y = c.y;
				sprite.rotation = angle;
			} else {
				sprite.graphics.clear();
				sprite.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
				sprite.graphics.moveTo(p1.px, p1.py);
				sprite.graphics.lineTo(p2.px, p2.py);
			}
		}
		
		
		/**
		 * Assigns a DisplayObject to be used when painting this constraint.
		 */ 
		public function setDisplay(d:DisplayObject, offsetX:Number=0, 
				offsetY:Number=0, rotation:Number=0):void {
			
			displayObject = d;
			displayObjectRotation = rotation;
			displayObjectOffset = new Vector(offsetX, offsetY);
		}
		
		
		/**
		 * @private
		 */
		internal function initDisplay():void {
			displayObject.x = displayObjectOffset.x;
			displayObject.y = displayObjectOffset.y;
			displayObject.rotation = displayObjectRotation;
			sprite.addChild(displayObject);
		}
		
							
		/**
		 * @private
		 */		
		internal function get delta():Vector {
			return p1.curr.minus(p2.curr);
		}
		

		/**
		 * Corrects the position of the attached particles based on their position and
		 *  mass. This method is called automatically during the APEngine.step() cycle.
		 */			
		public override function resolve():void {
			if (broken) return;
			
			var ang12:Number = Math.atan2(p2.curr.y - p1.curr.y, p2.curr.x - p1.curr.x);
			var ang23:Number = Math.atan2(p3.curr.y - p2.curr.y, p3.curr.x - p2.curr.x);
			
			var angDiff:Number = ang12 - ang23;
			while (angDiff > Math.PI) angDiff -= PI2;
			while (angDiff < -Math.PI) angDiff += PI2;
			
			var sumInvMass:Number = p1.invMass + p2.invMass;
			var mult1:Number = p1.invMass / sumInvMass;
			var mult2:Number = p2.invMass / sumInvMass;
			var angChange:Number = 0;
			
			var lowMid:Number = (maxAng - minAng) / 2;
			var highMid:Number = (maxAng + minAng) / 2;
     		var breakAng:Number = (maxBreakAng - minBreakAng) / 2;
			
     		var newDiff:Number = highMid - angDiff;
			while (newDiff > Math.PI) newDiff -= PI2;
			while (newDiff < -Math.PI) newDiff += PI2;
			
			if (newDiff > lowMid) {
				
				if (newDiff > breakAng) {
					var diff = newDiff - breakAng;
					broken = true;
					if (hasEventListener(BreakEvent.ANGULAR)) {
						dispatchEvent(new BreakEvent(BreakEvent.ANGULAR, diff));
					}
					return;
				}
				angChange = newDiff - lowMid;
			} else if (newDiff < -lowMid) {
				
				if (newDiff < - breakAng) {
					var diff2 = newDiff + breakAng;
					broken = true;
					if (hasEventListener(BreakEvent.ANGULAR)) {
						dispatchEvent(new BreakEvent(BreakEvent.ANGULAR, diff2));
					}
					return;
				}
				angChange = newDiff + lowMid;
			}
			
			var finalAng:Number = angChange * this.stiffness + ang12;
			var displaceX:Number = p1.curr.x + (p2.curr.x - p1.curr.x) * mult1;
			var displaceY:Number = p1.curr.y + (p2.curr.y - p1.curr.y) * mult1;
			
    		p1.curr.x = displaceX + Math.cos(finalAng + Math.PI) * _restLength * mult1;
    		p1.curr.y = displaceY + Math.sin(finalAng + Math.PI) * _restLength * mult1;
			p2.curr.x = displaceX + Math.cos(finalAng) * _restLength * mult2;
			p2.curr.y = displaceY + Math.sin(finalAng) * _restLength * mult2;	
		}
		
		
		/**
		 * if the any particles are at the same location warn the user
		 */
		private function checkParticlesLocation():void {

			var p1p2:Boolean = p1.curr.x == p2.curr.x && p1.curr.y == p2.curr.y;
			var p2p3:Boolean = p2.curr.x == p3.curr.x && p2.curr.y == p3.curr.y;
			var p1p3:Boolean = p1.curr.x == p3.curr.x && p1.curr.y == p3.curr.y;
			
			if (p1p2 || p2p3 || p1p3) {
				throw new Error("Two or more of the particles of the AngularConstraint are at the same location");		
			}
		}
	}
}

