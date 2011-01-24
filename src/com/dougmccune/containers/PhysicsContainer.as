package com.dougmccune.containers
{ 
	import com.dougmccune.foam.view.DisplayObjectFoamRenderer;
	
	import flash.display.DisplayObject;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	
	import org.generalrelativity.foam.Foam;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.dynamics.force.Friction;
	import org.generalrelativity.foam.dynamics.force.Gravity;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.util.ShapeUtil;

	public class PhysicsContainer extends Container
	{
		private var foam:Foam;
		
		private var leftWall:RigidBody;
		private var rightWall:RigidBody;
		private var topWall:RigidBody;
		private var bottomWall:RigidBody;
		
		public function PhysicsContainer()
		{
			super();
			
			foam = new Foam();
			foam.solverIterations = 4;
			foam.setRenderer( new DisplayObjectFoamRenderer() );
			foam.useMouseDragger( true );
			
			foam.addGlobalForceGenerator( new Friction( 0.01 ) );
		}
		
		override protected function createChildren():void {
			super.createChildren();
			rawChildren.addChild(foam);
		}
		
		private var _gravityForce:Gravity;
		
		public function setGravity(yValue:Number=0, xValue:Number=0):void {
			
			if(_gravityForce) {
				foam.removeGlobalForceGenerator(_gravityForce);
			}
			else {
				foam.simulate();
			}
			
			_gravityForce = new Gravity new  org.generalrelativity.foam.math.Vector(xValue, yValue) );
			foam.addGlobalForceGenerator(_gravityForce);
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			createWalls(unscaledWidth, unscaledHeight);
		}
		
		private function createWalls(w:Number, h:Number):void {
			foam.removeElement(bottomWall);
			bottomWall = new RigidBody( w/2, h + 10, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( w, 20 ) );
			foam.addElement( bottomWall, true, false);
			
			foam.removeElement(leftWall);
			leftWall = new RigidBody( -10, h/2, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 20, h ) );
			foam.addElement(leftWall, true, false);
			
			foam.removeElement(rightWall);
			rightWall = new RigidBody( w + 10, h/2, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 20, h ) );
			foam.addElement(rightWall, true, false);
			
			foam.removeElement(topWall);
			topWall = new RigidBody( w/2,-10, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( w, 20 ) );
			foam.addElement(topWall, true, false);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			var uiComp:UIComponent = new UIComponent();
			
			uiComp.addChild(child);
			
			if(child is UIComponent) {
				UIComponent(child).validateSize(true);
			}
			
			var childWidth:Number = child is UIComponent ? UIComponent(child).getExplicitOrMeasuredWidth() : child.width;
			var childHeight:Number = child is UIComponent ? UIComponent(child).getExplicitOrMeasuredHeight() : child.height;
			
			child.width = childWidth;
			child.height = childHeight;
			
			uiComp.x = child.x + childWidth/2;
			uiComp.y = child.y + childHeight/2;
			
			child.x = -child.width/2;
			child.y = -child.height/2;
			
			var body:RigidBody = new RigidBody(uiComp.x,uiComp.y, .5, ShapeUtil.createRectangle(childWidth, childHeight) );
			
			foam.addElement( body, true, true, uiComp );
			
			if(_gravityForce) {
				foam.simulate();
			}
			
			return super.addChild(uiComp);
		}
		
	}
}