
package org.cove.ape{  
    import flash.events.MouseEvent;  
    import org.cove.ape.*;  
    public class DragableCircleParticle extends CircleParticle{  
        private var mouseIsDown:Boolean;  
        public function DragableCircleParticle(  
                x:Number,  
                y:Number,  
                radius:Number,  
                fixed:Boolean = false,  
                mass:Number = 1,  
                elasticity:Number = 0.3,  
                friction:Number = 0){  
            super(x, y, radius, fixed, mass, elasticity, friction);  
            alwaysRepaint = fixed;  
            mouseIsDown = false;  
            sprite.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);   
        }  
        private function mouseDownHandler(evt:MouseEvent):void{  
            mouseIsDown = true;                 // on mouse down set mouseIsDown to true  
            curr.setTo(evt.stageX,evt.stageY);  // set the current position of the particle to the position of the mouse  
            prev.setTo(evt.stageX,evt.stageY);  // set the previous position of the particle to the position of the mouse  
        }  
        private function mouseUpHandler(evt:MouseEvent):void{  
            mouseIsDown = false;            // on mouse up set mouseIsDown to false  
        }  
        private function mouseMoveHandler(evt:MouseEvent):void{  
            if(mouseIsDown){                // On mouse move if the mouse is down  
                prev.copy(curr);            // set the previous position to the curent position of the particle  
                curr.setTo(evt.stageX,evt.stageY);  // set the current position to the position of the mouse  
            }  
        }  
        public override function update(dt2:Number):void {  
            if(!mouseIsDown){       // Don't update if the mouse is down  
                super.update(dt2);  
            }  
        }  
    }  
}