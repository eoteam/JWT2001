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
	
	
	public class RigidRectangle extends RigidItem{
		private var _extents:Array;
		private var _axes:Array;
		private var _vertices:Array;
		private var _marginCenters:Array;
		private var _normals:Array;

		function RigidRectangle(
				x:Number, 
				y:Number, 
				width:Number,
				height:Number,
				radian:Number=0,
				isFixed:Boolean=false, 
				mass:Number=-1, 
				elasticity:Number=0.3,
				friction:Number=0.2,
				angularVelocity:Number=0) {
			if(mass==-1){
				mass=width*height;
			}
			super(x,y,Math.sqrt(width*width/4+height*height/4),isFixed,mass,mass*(width*width+height*height)/12,elasticity,friction,radian,angularVelocity);
			_extents = new Array(width/2, height/2);
			_axes = new Array(new MyVector(0,0), new MyVector(0,0));
			_normals=new Array();
			_marginCenters=new Array();
			_vertices=new Array();
			for(var i:int=0;i<4;i++){
				_normals.push(new MyVector(0,0));
				_marginCenters.push(new MyVector(0,0));
				_vertices.push(new MyVector(0,0));
			}
		}
		public override function drawShape(graphics:Graphics):void{
			var w:Number = extents[0] * 2;
			var h:Number = extents[1] * 2;
			
			sprite.graphics.clear();
			sprite.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			sprite.graphics.beginFill(fillColor, fillAlpha);
			sprite.graphics.drawRect(-w/2, -h/2, w, h);
			sprite.graphics.endFill();
		}
		public override function setAxes(n:Number):void{
			var s:Number = Math.sin(n);
			var c:Number = Math.cos(n);
			axes[0].x = c;
			axes[0].y = s;
			axes[1].x = -s;
			axes[1].y = c;
			//
			_normals[0].copy(axes[0]);
			_normals[1].copy(axes[1]);
			_normals[2]=axes[0].mult(-1);
			_normals[3]=axes[1].mult(-1);
			//.plusEquals(curr)
			_marginCenters[0]=axes[0].mult( extents[0]);
			_marginCenters[1]=axes[1].mult( extents[1]);
			_marginCenters[2]=axes[0].mult(-extents[0]);
			_marginCenters[3]=axes[1].mult(-extents[1]);
			//.minusEquals(curr)
			_vertices[0]=_marginCenters[0].plus(_marginCenters[1]);
			_vertices[1]=_marginCenters[1].plus(_marginCenters[2]);
			_vertices[2]=_marginCenters[2].plus(_marginCenters[3]);
			_vertices[3]=_marginCenters[3].plus(_marginCenters[0]);
		}
		public override function captures(vertex:MyVector):Boolean{
			for(var i:int=0;i<_marginCenters.length;i++){
				var x:Number=vertex.minus(_marginCenters[i].plus(samp)).dot(_normals[i]);
				if(x>0.01){
					return false;
				}
			}
			return true;
		}
		public function get axes():Array {
			return _axes;
		}
		public function get extents():Array {
			return _extents;
		}
		public function getVertices():Array{
			var r:Array=new Array();
			for(var i:int=0;i<_vertices.length;i++){
				r.push(_vertices[i].plus(samp));
			}
			return r;
		}
		public function getNormals():Array{
			return _normals;
		}
		public function getMarginCenters():Array{
			return _marginCenters;
		}
		internal function getProjection(axis:MyVector):Interval {
			
			var radius:Number =
			    extents[0] * Math.abs(axis.dot(axes[0]))+
			    extents[1] * Math.abs(axis.dot(axes[1]));
			
			var c:Number = samp.dot(axis);
			
			interval.min = c - radius;
			interval.max = c + radius;
			return interval;
		}
	}
}