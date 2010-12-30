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
- provide passible MVectors for results. too much object creation happening here
- review the division by zero checks/corrections. why are they needed?
*/

package org.cove.ape {
	
	public class MVector {
		
		public var x:Number;
		public var y:Number;
	
	
		public function MVector(px:Number = 0, py:Number = 0) {
			x = px;
			y = py;
		}
		
		
		public function setTo(px:Number, py:Number):void {
			x = px;
			y = py;
		}
		
		
		public function copy(v:MVector):void {
			x = v.x;
			y = v.y;
		}
	
	
		public function dot(v:MVector):Number {
			return x * v.x + y * v.y;
		}
		
		
		public function cross(v:MVector):Number {
			return x * v.y - y * v.x;
		}
		
	
		public function plus(v:MVector):MVector {
			return new MVector(x + v.x, y + v.y); 
		}
	
		
		public function plusEquals(v:MVector):MVector {
			x += v.x;
			y += v.y;
			return this;
		}
		
		
		public function minus(v:MVector):MVector {
			return new MVector(x - v.x, y - v.y);    
		}
	
	
		public function minusEquals(v:MVector):MVector {
			x -= v.x;
			y -= v.y;
			return this;
		}
	
	
		public function mult(s:Number):MVector {
			return new MVector(x * s, y * s);
		}
	
	
		public function multEquals(s:Number):MVector {
			x *= s;
			y *= s;
			return this;
		}
	
	
		public function times(v:MVector):MVector {
			return new MVector(x * v.x, y * v.y);
		}
		
		
		public function divEquals(s:Number):MVector {
			if (s == 0) s = 0.0001;
			x /= s;
			y /= s;
			return this;
		}
		
		
		public function magnitude():Number {
			return Math.sqrt(x * x + y * y);
		}

		
		public function distance(v:MVector):Number {
			var delta:MVector = this.minus(v);
			return delta.magnitude();
		}

	
		public function normalize():MVector {
			 var m:Number = magnitude();
			 if (m == 0) m = 0.0001;
			 return mult(1 / m);
		}
		
				
		public function toString():String {
			return (x + " : " + y);
		}
	}
}