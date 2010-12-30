package org.cove.ape {
	
	public interface IRigidItem{
		function resolveRigidCollision(
				aa:Number, mtd:Vector, vel:Vector, n:Vector, 
				d:Number, o:int, p:AbstractParticle):void;
		/*function getVertices(axis:Array):Array;
		function getNormals():Array;
		function set k(n:Number);
		function get k():Number;*/
	}
}