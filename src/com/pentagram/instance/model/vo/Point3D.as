package com.pentagram.instance.model.vo
{
    import flash.geom.*;

    public class Point3D extends Point {
        public var z:Number = 0;

        public function Point3D(x:Number = 0, y:Number = 0, z:Number = 0) {
            super(x, y);
            this.z = z;
            return;
        }// end function

        public function toVector3D() : Vector3D {
            return new Vector3D(x, y, this.z);
        }// end function

        override public function toString() : String {
            return "Point3D[x=" + x + ", y=" + y + ", z=" + this.z + "]";
        }// end function

        override public function clone() : Point {
            return new Point3D(x, y, this.z);
        }// end function

        override public function equals(toCompare:Point) : Boolean {
            if (toCompare is Point3D){
                if (super.equals(toCompare)){
                    super.equals(toCompare);
                }
                return this.z == (toCompare as Point3D).z;
            }
            return false;
        }// end function

    }
}
