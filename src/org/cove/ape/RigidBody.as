package org.cove.ape{
	public class RigidBody{
		public var item:AbstractParticle;
		private var _angularVelocity:Number;
		private var _frictionalCoefficient:Number;
		private var _radian:Number;
		function RigidBody(item:AbstractParticle,rotation:Number,av:Number,fr:Number){
			this.item=item;
			_radian=rotation;
			_angularVelocity=av;
			_frictionalCoefficient=fr;
		}
		public function set frictionalCoefficient(n):void{
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
		public override function update(dt2:Number):void {
			radian+=_angularVelocity*dt2;
		}
		public function resolveCollision(hitpoint,normal,depth){
		}
	}
}