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
- multisampling is buggy. needs to be replaced with swept tests
- get rid of all the object testing and use the double dispatch pattern
- depths in obbvscircle should not be instantiated each time
*/

package org.cove.ape {
	

	public  class CollisionDetector {	
		
		private static var cpa:AbstractParticle;
		private static var cpb:AbstractParticle;
		private static var collNormal:MyVector;
		private static var collDepth:Number;
			

		/**
		 * Tests the collision between two objects. This initial test determines
		 * the multisampling state of the two particles.
		 */	
		public static function test(objA:AbstractParticle, objB:AbstractParticle):void {
			
			if (objA.fixed && objB.fixed) return;
			
			if (objA.multisample == 0 && objB.multisample == 0) {
				normVsNorm(objA, objB);
							
			} else if (objA.multisample > 0 && objB.multisample == 0) {
				sampVsNorm(objA, objB);
				
			} else if (objB.multisample > 0 && objA.multisample == 0) {
				sampVsNorm(objB, objA);

			} else if (objA.multisample == objB.multisample) {
				sampVsSamp(objA, objB);

			} else {
				normVsNorm(objA, objB);
			}
		}
		
		
		/**
		 * default test for two non-multisampled particles
		 */
		public static function normVsNorm(
				objA:AbstractParticle, objB:AbstractParticle):Boolean {
					
			objA.samp.copy(objA.curr);
			objB.samp.copy(objB.curr);
			if (testTypes(objA, objB)) {
				CollisionResolver.resolve(cpa, cpb, collNormal, collDepth);
				return true;
			}
			return false
		}
		
		
		/**
		 * Tests two particles where one is multisampled and the other is not. Let objectA
		 * be the multisampled particle.
		 */
		public static function sampVsNorm(
				objA:AbstractParticle, objB:AbstractParticle):void {
			
			if (normVsNorm(objA,objB)) return;
			
			var s:Number = 1 / (objA.multisample + 1); 
			var t:Number = s;
			
			for (var i:int = 0; i <= objA.multisample; i++) {
				objA.samp.setTo(objA.prev.x + t * (objA.curr.x - objA.prev.x), 
								objA.prev.y + t * (objA.curr.y - objA.prev.y));
				
				if (testTypes(objA, objB)) {
					CollisionResolver.resolve(cpa, cpb, collNormal, collDepth);
					return;
				}
				t += s;
			}
		}


		/**
		 * Tests two particles where both are of equal multisample rate
		 */		
		public static function sampVsSamp(
				objA:AbstractParticle, objB:AbstractParticle):void {
			
			if (normVsNorm(objA,objB)) return;
			
			var s:Number = 1 / (objA.multisample + 1); 
			var t:Number = s;
			
			for (var i:int = 0; i <= objA.multisample; i++) {
				
				objA.samp.setTo(objA.prev.x + t * (objA.curr.x - objA.prev.x), 
								objA.prev.y + t * (objA.curr.y - objA.prev.y));
				
				objB.samp.setTo(objB.prev.x + t * (objB.curr.x - objB.prev.x), 
								objB.prev.y + t * (objB.curr.y - objB.prev.y));
				
				if (testTypes(objA, objB)) {
					CollisionResolver.resolve(cpa, cpb, collNormal, collDepth);
					return;	
				} 
				t += s;
			}
		}
		
		
		/**
		 * Tests collision based on primitive type.
		 */	
		public static function testTypes(
				objA:AbstractParticle, objB:AbstractParticle):Boolean {	
			//Following code was added for rigidAPE
			//trace((objA is RigidItem) +" "+ (objB is RigidItem));
			if (objA is RigidItem && objB is RigidItem) {
				testTypes2(objA,objB);
				return false;
			}
			//end of RigidAPE code
			if (objA is RectangleParticle && objB is RectangleParticle) {
				return testOBBvsOBB(objA, objB);
			
			} else if (objA is CircleParticle && objB is CircleParticle) {
				return testCirclevsCircle(objA, objB);
				
			} else if (objA is RectangleParticle && objB is CircleParticle) {
				return testOBBvsCircle(objA, objB);
				
			} else if (objA is CircleParticle && objB is RectangleParticle)  {
				return testOBBvsCircle(objB, objA);
			}
			
			return false;
		}
	
	
		/**
		 * Tests the collision between two RectangleParticles (aka OBBs). If there is a 
		 * collision it determines its axis and depth, and then passes it off to the 
		 * CollisionResolver for handling.
		 */
		public static function testOBBvsOBB(
				ra, rb):Boolean {
			
			collDepth = Number.POSITIVE_INFINITY;
			//trace(ra);
			for (var i:int = 0; i < 2; i++) {
		
			    var axisA:MyVector = ra.axes[i];
			    var depthA:Number = testIntervals(
			    		ra.getProjection(axisA), rb.getProjection(axisA));
			    if (depthA == 0) return false;
				
			    var axisB:MyVector = rb.axes[i];
			    var depthB:Number = testIntervals(
			    		ra.getProjection(axisB), rb.getProjection(axisB));
			    if (depthB == 0) return false;
			    
			    var absA:Number = Math.abs(depthA);
			    var absB:Number = Math.abs(depthB);
			    
			    if (absA < Math.abs(collDepth) || absB < Math.abs(collDepth)) {
			    	var altb:Boolean = absA < absB;
			    	collNormal = altb ? axisA : axisB;
			    	collDepth = altb ? depthA : depthB;
			    }
			}
			
			cpa = ra;
			cpb = rb
			return true;
		}		
	
	
		/**
		 * Tests the collision between a RectangleParticle (aka an OBB) and a 
		 * CircleParticle. If there is a collision it determines its axis and depth, and 
		 * then passes it off to the CollisionResolver.
		 */
		public static function testOBBvsCircle(ra, ca):Boolean {
			 
			collDepth = Number.POSITIVE_INFINITY;
			var depths:Array = new Array(2);
			
			// first go through the axes of the rectangle
			for (var i:int = 0; i < 2; i++) {
	
				var boxAxis:MyVector = ra.axes[i];
				var depth:Number = testIntervals(
						ra.getProjection(boxAxis), ca.getProjection(boxAxis));
				if (depth == 0) return false;
	
				if (Math.abs(depth) < Math.abs(collDepth)) {
					collNormal = boxAxis;
					collDepth = depth;
				}
				depths[i] = depth;
			}	
			
			// determine if the circle's center is in a vertex region
			var r:Number = ca.radius;
			if (Math.abs(depths[0]) < r && Math.abs(depths[1]) < r) {
	
				var vertex:MyVector = closestVertexOnOBB(ca.samp, ra);
	
				// get the distance from the closest vertex on rect to circle center
				collNormal = vertex.minus(ca.samp);
				var mag:Number = collNormal.magnitude();
				collDepth = r - mag;
	
				if (collDepth > 0) {
					// there is a collision in one of the vertex regions
					collNormal.divEquals(mag);
				} else {
					// ra is in vertex region, but is not colliding
					return false;
				}
			}
			
			cpa = ra;
			cpb = ca
			return true;
		}
	
	
		/**
		 * Tests the collision between two CircleParticles. If there is a collision it 
		 * determines its axis and depth, and then passes it off to the CollisionResolver
		 * for handling.
		 */	
		public static function testCirclevsCircle(
				ca, cb):Boolean {
			
			var depthX:Number = testIntervals(ca.getIntervalX(), cb.getIntervalX());
			if (depthX == 0) return false;
			
			var depthY:Number = testIntervals(ca.getIntervalY(), cb.getIntervalY());
			if (depthY == 0) return false;
			
			collNormal = ca.samp.minus(cb.samp);
			var mag:Number = collNormal.magnitude();
			collDepth = (ca.radius + cb.radius) - mag;
			
			if (collDepth > 0) {
				collNormal.divEquals(mag);
				cpa = ca;
				cpb = cb
				return true;
			}
			return false;
		}
	
	
		/**
		 * Returns 0 if intervals do not overlap. Returns smallest depth if they do.
		 */
		public static function testIntervals(
				intervalA:Interval, intervalB:Interval):Number {
			
			if (intervalA.max < intervalB.min) return 0;
			if (intervalB.max < intervalA.min) return 0;
			
			var lenA:Number = intervalB.max - intervalA.min;
			var lenB:Number = intervalB.min - intervalA.max;
			
			return (Math.abs(lenA) < Math.abs(lenB)) ? lenA : lenB;
		}
		
		
		/**
		 * Returns the location of the closest vertex on r to point p
		 */
	 	public static function closestVertexOnOBB(p:MyVector, r):MyVector {
	
			var d:MyVector = p.minus(r.samp);
			var q:MyVector = new MyVector(r.samp.x, r.samp.y);
	
			for (var i:int = 0; i < 2; i++) {
				var dist:Number = d.dot(r.axes[i]);
	
				if (dist >= 0) dist = r.extents[i];
				else if (dist < 0) dist = -r.extents[i];
	
				q.plusEquals(r.axes[i].mult(dist));
			}
			return q;
		}
		public static var hitpoint:Array=new Array();
		public static var hp:MyVector=new MyVector();
		//:Vector=new Vector();

		public static function testTypes2(
				objA:AbstractParticle, objB:AbstractParticle):Boolean {
			var result:Boolean=false;
			var result2:Boolean=false;
			hitpoint=new Array();
			if (objA is RigidRectangle && objB is RigidRectangle) {
				//trace(objA+" "+objB);
				result = testOBBvsOBB(objA, objB);
				if(result){
					result2=findHitPointRR(objA as RigidRectangle,objB as RigidRectangle);
				}
			} else if (objA is RigidCircle && objB is RigidCircle) {
				result = testCirclevsCircle(objA, objB);
				if(result){
					result2=findHitPointCC(objA as RigidCircle,objB as RigidCircle);
				}
			} else if (objA is RigidRectangle && objB is RigidCircle) {
				result = testOBBvsCircle(objA, objB);
				if(result){
					result2=findHitPointRC(objA as RigidRectangle,objB as RigidCircle);
				}
			} else if (objA is RigidCircle && objB is RigidRectangle)  {
				result = testOBBvsCircle(objB, objA);
				if(result){
					result2=findHitPointRC(objB as RigidRectangle,objA as RigidCircle);
					if(result2){
						getHP();
						RigidCollisionResolver.resolve(objB,objA,hp,collNormal,collDepth);
						return false;
					}
				}
			}
			if(result2){
				getHP();
				RigidCollisionResolver.resolve(objA,objB,hp,collNormal,collDepth);
				return false;
			}else{
				return result;
			}
		}
		public static function getHP():void{
			hp=new MyVector();
			for(var i:int=0;i<hitpoint.length;i++){
				hp.plusEquals(hitpoint[i]);
			}
			if(hitpoint.length>1){
				//trace(hitpoint.length+" hitpoints");
				hp.multEquals(1/hitpoint.length);
			}
		}
		public static function captures(r:RigidItem,vertices:Array):Boolean{
			//trace(r+" "+vertices);
			var re:Boolean=false;
			for(var i:int=0;i<vertices.length;i++){
				if(r.captures(vertices[i])){
					//hitpoint.copy(vertices[i]);
					hitpoint.push(vertices[i]);
					re= true;
				}
			}
			return re;
		}
		public static function findHitPointRR(a:RigidRectangle,b:RigidRectangle):Boolean{
			var r:Boolean=false;
			if(captures(a,b.getVertices())){
				r = true;
			}
			if(captures(b,a.getVertices())){
				r=true;
			}
			return r;
		}
		public static function findHitPointRC(a:RigidRectangle,b:RigidCircle):Boolean{
			//trace("r v c");
			var r:Boolean=false;
			if(captures(b,a.getVertices())){
				r = true;
			}
			if(captures(a,b.getVertices(a.getNormals()))){
				r = true;
			}
			return r;
		}
		public static function findHitPointCC(a:RigidCircle,b:RigidCircle):Boolean{
			//trace("c v c");
			var d:MyVector=b.samp.minus(a.samp);
			if(d.magnitude()<=(a.range+b.range)){
				//hitpoint.copy(d.normalize().multEquals(a.range).plusEquals(a.samp));
				hitpoint.push(d.normalize().multEquals(a.range).plusEquals(a.samp));
				return true;
			}else{
				return false;
			}
		}
		public function CollisionDetector():void
		{
			
		}
	}
}
