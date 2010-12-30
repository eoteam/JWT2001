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
	public class RigidCollisionResolver{
		static public function resolve(pa,pb,hitpoint:MyVector,normal:MyVector,depth:Number):void{
			//trace("hit "+normal+" "+depth);
            var mtd:MyVector = normal.mult(depth);           
            var te:Number = pa.elasticity + pb.elasticity;
            var sumInvMass:Number = pa.invMass + pb.invMass;
            //rewrite collision resolve
			var vap	= pa.getVelocityOn(hitpoint);
			var vbp	= pb.getVelocityOn(hitpoint);
			//trace(vap+" "+vbp);
			var vabp:MyVector= vap.minus(vbp);
			var vn:MyVector	= normal.mult(vabp.dot(normal));
			var l:MyVector	= vabp.minus(vn).normalize();
			var n:MyVector	= normal.plus(l.mult(-0.1)).normalize();
			var ra:MyVector	= hitpoint.minus(pa.samp);
			var rb:MyVector	= hitpoint.minus(pb.samp);
			var raxn:Number= ra.cross(n);
			var rbxn:Number= rb.cross(n);
			var j:Number	= -vabp.dot(n)*(1+te/2)/(sumInvMass+raxn*raxn/pa.mi+rbxn*rbxn/pb.mi);
			var vna:MyVector	= pa.velocity.plus(n.mult( j*pa.invMass));
			var vnb:MyVector	= pb.velocity.plus(n.mult(-j*pb.invMass));
			//trace(j+" "+pb.velocity+"\t+"+n.mult(-j*pb.invMass)+"\t="+vnb+" "+vna);
			//trace(pa.angularVelocity+" "+pa.radian+" "+pb.angularVelocity+" "+pb.radian);
			var aaa:Number	= j*raxn/pa.mi;
			var aab:Number	=-j*rbxn/pb.mi;
			if(Math.abs(aaa)>0.1 || Math.abs(aab)>0.1){
				trace(" "+aaa+" "+aab);
			}
			pa.resolveRigidCollision(aaa,pb);
			pb.resolveRigidCollision(aab,pa);
            var mtdA:MyVector = mtd.mult( pa.invMass / sumInvMass);     
            var mtdB:MyVector = mtd.mult(-pb.invMass / sumInvMass);
			pa.resolveCollision(mtdA, vna, normal, depth, -1, pb);
			pb.resolveCollision(mtdB, vnb, normal, depth,  1, pa);
			//end collision resolve
		}
	}
}