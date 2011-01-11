package com.pentagram.instance.view.visualizer
{
    import Box2D.Collision.Shapes.b2CircleShape;
    import Box2D.Collision.Shapes.b2PolygonDef;
    import Box2D.Collision.Shapes.b2PolygonShape;
    import Box2D.Collision.Shapes.b2Shape;
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Mat22;
    import Box2D.Common.Math.b2Math;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.Joints.b2Joint;
    import Box2D.Dynamics.Joints.b2MouseJoint;
    import Box2D.Dynamics.Joints.b2MouseJointDef;
    import Box2D.Dynamics.Joints.b2PulleyJoint;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2World;
    
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.collections.ArrayCollection;
    import mx.core.IVisualElement;
    import mx.events.CollectionEvent;
    
    import spark.components.Button;
    import spark.components.Group;
    import spark.components.SkinnableContainer;
    import spark.components.supportClasses.SkinnableComponent;
    import spark.events.ElementExistenceEvent;
    
    public class SkinnablePhysicsContainer extends SkinnableContainer
    {
        public static const FRICTION:Number = 0.3;
        public static const ADJUSTMENT:Number = 12;
        public static const ITERATIONS:Number = 10;
        public static const TIMESTEP:Number = 1 / 60;
        
        
        private var _mouseXWorldPhys:Number;
        private var _mouseYWorldPhys:Number;
        private var _mouseVector:b2Vec2 = new b2Vec2();
        private var _mouseDown:Boolean = false;
        private var _mouseJoint:b2MouseJoint = null;
        
        private var _physicsBodies:ArrayCollection = new ArrayCollection();
        private var _physicsTargets:ArrayCollection = new ArrayCollection();
        
        
        
        /**
         * Constructor
         */
        public function SkinnablePhysicsContainer()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, addedToStage_handler);
            addEventListener(ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
            addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this
        }
        
        
        
        /**
         * addedToStage_handler
         * 
         * Initializes world and creates the boundaries. Next, mappings are created for each skinnable component
         * that exists within the actual container.
         */
        private function addedToStage_handler(event:Event):void
        {
            trace("SkinnablePhysicsContainer.addedToStage_handler(): width/height = " + this.width + "/" + this.height);
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage_handler);
            
            initializeWorld();
            createBoundaries();
			for each (var nextVisualElement:IVisualElement in _physicsTargets)
			{
				// add them to the physics world
				_physicsBodies.addItem(createBody(SkinnableComponent(nextVisualElement)));
			}

        }
        override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName,instance);
			if(instance is Button) {
				_physicsTargets.addItem(instance as IVisualElement);
				_physicsBodies.addItem(createBody(SkinnableComponent(instance)));
			}
		}
        
        
        /**
         * contentGroup_elementAddedHandler
         * 
         * Adds the newly added element to the list of targets for which physics will be applied.
         */
        private function contentGroup_elementAddedHandler(elementExistenceEvent:ElementExistenceEvent):void
        {
            var addedElement:IVisualElement = elementExistenceEvent.element;
            
            if (addedElement is SkinnableComponent)
            {
                _physicsTargets.addItem(addedElement);
            }
        }
        
        
        
        /**
         * contentGroup_elementRemovedHandler
         * 
         * Removes the element from the list of targets for which physics was being applied and also removes
         * the mapping associated with the element.
         */
        private function contentGroup_elementRemovedHandler(elementExistenceEvent:ElementExistenceEvent):void
        {
            var removedElement:IVisualElement = elementExistenceEvent.element;
        }
        
        
        
        private function createBody(actualTarget:SkinnableComponent):b2Body
        {
            
            // create the body defintion
            var bodyDef:b2BodyDef = new b2BodyDef();
            // position the body
            bodyDef.position.Set(actualTarget.x, actualTarget.y);
            // rotate the body
            bodyDef.angle = actualTarget.rotation * Math.PI / 180;
            // associate the actualTarget with the body
            bodyDef.userData = actualTarget;
            
            // create the body from the body defintion
            var returnBody:b2Body = world.CreateBody(bodyDef);
            
            // create the shape defintion
            var bodyShapeDef:b2PolygonDef = new b2PolygonDef();
            
            // extents are a vector that goes from one corner of the box to the center (ie 1/2 width and height)
            bodyShapeDef.SetAsOrientedBox(actualTarget.width/2, actualTarget.height/2, new b2Vec2(actualTarget.width/2, actualTarget.height/2), 0);
            // density is used in the collisions equation to be density*area=mass
            // a density of 0 or null will make the object static, never moving in the case of a collision or gravity
            bodyShapeDef.density = 50.0;
            // friction is used to calculate the friction between two objects; it should be between 0.0 and 1.0
            bodyShapeDef.friction = 0.5;
            // restitution is the bounciness of the object; it should be between 0.0 and 1.0
            bodyShapeDef.restitution = 0.1;
            
            // create the shape from the shape definition
            returnBody.CreateShape(bodyShapeDef);
            
            returnBody.SetMassFromShapes();
            
            return returnBody;
        }
        
        
        
        /**
         * Accessor that starts/stop the physics world.
         */
        private var _physicsEnabled:Boolean = false;
        [Bindable]
        public function get physicsEnabled():Boolean
        {
            return _physicsEnabled;
        }
        public function set physicsEnabled(value:Boolean):void
        {
            if (value != _physicsEnabled)
            {
                _physicsEnabled = value;
                
                if (_physicsEnabled)
                {
                    addEventListener(Event.ENTER_FRAME, enterFrame_handler);
                }
                else
                {
                    removeEventListener(Event.ENTER_FRAME, enterFrame_handler);
                }
            }
        }
        
        
        
        /**
         * enterFrame_handler
         * 
         * Applies physics to the actual container children for each frame.
         */
        private function enterFrame_handler(event:Event):void
        {
            updateMouse();
            mouseDrag();
            world.Step(TIMESTEP, ITERATIONS);
            this.contentGroup.graphics.clear();
            
            // DEBUG
            for (var nextJoint:b2Joint = world.m_jointList; nextJoint; nextJoint = nextJoint.m_next)
            {
                drawJoint(nextJoint);
            }
            for each (var nextBody:b2Body in _physicsBodies)
            {
                // DEBUG
                drawShape(nextBody.GetShapeList());
                
                var actualElement:SkinnableComponent = SkinnableComponent(nextBody.GetUserData());
                
                actualElement.x = nextBody.GetPosition().x;
                actualElement.y = nextBody.GetPosition().y;
                actualElement.rotation = nextBody.GetAngle() * (180/Math.PI);
            }
        }
        
        
        
        /**
         * initializeWorld
         * 
         * Creates the physics world that mirrors the actual container.
         */
        private function initializeWorld():void
        {
            trace("PhysicsWorld.initializeWorld()");
            // create coordinate system for the world
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(-this.width, -this.height);
            worldAABB.upperBound.Set(this.width, this.height);
            // define the gravity vector for the world
            var gravity:b2Vec2 = new b2Vec2(0, 600);
            // allow bodies to sleep in the world
            var doSleep:Boolean = true;
            // construct a world object
            this.world = new b2World(worldAABB, gravity, doSleep);
        }
        
        
        
        private var _world:b2World = null;
        [Bindable]
        public function get world():b2World
        {
            return _world;
        }
        public function set world(value:b2World):void
        {
            _world = value;
        }
        
        
        
        private var _physicsScale:Number = 1;
        [Bindable]
        public function get physicsScale():Number
        {
            return _physicsScale;
        }
        public function set physicsScale(value:Number):void
        {
            _physicsScale = value;
        }
        
        
        
        /**
         * Creates the boundaries within the world that will mirror the bounds of the container.
         */
        public function createBoundaries():void
        {
            var boundaryWidth:Number = 20;
            
            var bodyDef:b2BodyDef;
            var body:b2Body;
            var bodyShapeDef:b2PolygonDef;
            
            // left boundary
            bodyDef = new b2BodyDef();
            bodyDef.position.Set(boundaryWidth/2-ADJUSTMENT, this.height/2);
            body = world.CreateBody(bodyDef);
            bodyShapeDef = new b2PolygonDef();
            bodyShapeDef.SetAsBox(boundaryWidth, this.height/2);
            body.CreateShape(bodyShapeDef);
            
            // right boundary
            bodyDef = new b2BodyDef();
            bodyDef.position.Set(this.width - boundaryWidth/2 + ADJUSTMENT, this.height/2);
            body = world.CreateBody(bodyDef);
            bodyShapeDef = new b2PolygonDef();
            bodyShapeDef.SetAsBox(boundaryWidth, this.height/2);
            body.CreateShape(bodyShapeDef);
            
            // top boundary
            bodyDef = new b2BodyDef();
            bodyDef.position.Set(this.width/2, boundaryWidth/2-ADJUSTMENT);
            body = world.CreateBody(bodyDef);
            bodyShapeDef = new b2PolygonDef();
            bodyShapeDef.SetAsBox(this.width/2, boundaryWidth);
            body.CreateShape(bodyShapeDef);
            
            // bottom boundary
            bodyDef = new b2BodyDef();
            bodyDef.position.Set(this.width/2, this.height-boundaryWidth/2+ADJUSTMENT);
            body = world.CreateBody(bodyDef);
            bodyShapeDef = new b2PolygonDef();
            bodyShapeDef.SetAsBox(this.width/2, boundaryWidth);
            body.CreateShape(bodyShapeDef);
        }
        
        
        
        private function updateMouse():void
        {
            _mouseXWorldPhys = (mouseX-10) / physicsScale;
            _mouseYWorldPhys = (mouseY-10) / physicsScale;
        }
        
        
        
        private function getBodyAtMouse():b2Body
        {
            _mouseVector.Set(mouseX, mouseY);
            var aabb:b2AABB = new b2AABB();
            aabb.lowerBound.Set(mouseX - 0.001, mouseY - 0.001);
            aabb.upperBound.Set(mouseX + 0.001, mouseY + 0.001);
            // query the world for overlapping shapes
            var shapes:Array = new Array();
            var count:int = world.Query(aabb, shapes, 10);
            var body:b2Body = null;
            
            for (var i:int = 0; i < count; ++i)
            {
                var inside:Boolean = shapes[i].TestPoint((shapes[i] as b2PolygonShape).GetBody().GetXForm(),  _mouseVector);
                if (inside)
                {
                    body = shapes[i].m_body;
                    break;
                }
            }
            return body;
        }
        
        
        
        private function mouseDrag():void
        {
            if (_mouseDown && !_mouseJoint)
            {
                var bodyAtMouse:b2Body = getBodyAtMouse();
                if (bodyAtMouse)
                {
                    var mouseJointDef:b2MouseJointDef = new b2MouseJointDef();
                    mouseJointDef.body1 = world.m_groundBody;
                    mouseJointDef.body2 = bodyAtMouse;
                    mouseJointDef.target.Set(mouseX, mouseY);
                    mouseJointDef.maxForce = 30000.0 * bodyAtMouse.m_mass;
                    mouseJointDef.timeStep = TIMESTEP;
                    
                    _mouseJoint = world.CreateJoint(mouseJointDef) as b2MouseJoint;
                    bodyAtMouse.WakeUp();
                }
            }
            
            if (!_mouseDown)
            {
                if (_mouseJoint)
                {
                    world.DestroyJoint(_mouseJoint);
                    _mouseJoint = null;
                }
            }
            
            if (_mouseJoint)
            {
                var p2:b2Vec2 = new b2Vec2(mouseX, mouseY);
                _mouseJoint.SetTarget(p2);
            }
        }
        
        
        
        private function mouseDownHandler(mouseEvent:MouseEvent):void
        {
            _mouseDown = true;
        }
        
        
        
        private function mouseUpHandler(mouseEvent:MouseEvent):void
        {
            _mouseDown = false;
        }
        
        
        
        public function drawJoint(joint:b2Joint):void
        {
            var body1:b2Body = joint.m_body1;
            var body2:b2Body = joint.m_body2;
            
            var body1Position:b2Vec2 = body1.GetPosition();
            var body2Position:b2Vec2 = body2.GetPosition();
            
            var body1Anchor:b2Vec2 = joint.GetAnchor1();
            var body2Anchor:b2Vec2 = joint.GetAnchor2();
            
            var containerGraphics:Graphics = this.contentGroup.graphics;
            
            containerGraphics.lineStyle(1, 0x501DFF, 1);
            
            switch (joint.m_type)
            {
                case b2Joint.e_distanceJoint:
                case b2Joint.e_mouseJoint:
                {
                    containerGraphics.moveTo(body1Anchor.x * physicsScale, body1Anchor.y * physicsScale);
                    containerGraphics.lineTo(body2Anchor.x * physicsScale, body2Anchor.y * physicsScale);
                    break;
                }
                case b2Joint.e_pulleyJoint:
                {
                    var pulley:b2PulleyJoint = joint as b2PulleyJoint;
                    var s1:b2Vec2 = pulley.GetGroundAnchor1();
                    var s2:b2Vec2 = pulley.GetGroundAnchor2();
                    containerGraphics.moveTo(s1.x * physicsScale, s1.y * physicsScale);
                    containerGraphics.lineTo(body1Anchor.x * physicsScale, body1Anchor.y * physicsScale);
                    containerGraphics.moveTo(s2.x * physicsScale, s2.y * physicsScale);
                    containerGraphics.lineTo(body2Anchor.x * physicsScale, body2Anchor.y * physicsScale);
                    break;
                }
                default:
                {
                    if (body1 == world.m_groundBody)
                    {
                        containerGraphics.moveTo(body1Anchor.x * physicsScale, body1Anchor.y * physicsScale);
                        containerGraphics.lineTo(body2Position.x * physicsScale, body2Position.y * physicsScale);
                    }
                    else 
                        if (body2 == world.m_groundBody)
                        {
                            containerGraphics.moveTo(body1Anchor.x * physicsScale, body1Anchor.y * physicsScale);
                            containerGraphics.lineTo(body1Position.x * physicsScale, body1Position.y * physicsScale);
                        }
                        else
                        {
                            containerGraphics.moveTo(body1Position.x * physicsScale, body1Position.y * physicsScale);
                            containerGraphics.lineTo(body1Anchor.x * physicsScale, body1Anchor.y * physicsScale);
                            containerGraphics.lineTo(body2Position.x * physicsScale, body2Position.y * physicsScale);
                            containerGraphics.lineTo(body2Anchor.x * physicsScale, body2Anchor.y * physicsScale);
                        }
                    break;
                }
            }
        }
        
        
        
        public function drawShape(shape:b2Shape):void
        {
            var v:b2Vec2 = null;
            var containerGraphics:Graphics = this.contentGroup.graphics;
            containerGraphics.lineStyle(1, 0x333333, 1);
            
            switch (shape.GetType())
            {
                case b2Shape.e_circleShape:
                {
                    var circleShape:b2CircleShape = shape as b2CircleShape;
                    var pos:b2Vec2 = circleShape.GetBody().GetPosition();
                    var r:Number = circleShape.GetRadius();
                    var k_segments:Number = 16.0;
                    var k_increment:Number = 2.0 * Math.PI / k_segments;
                    containerGraphics.moveTo((pos.x + r) * physicsScale, (pos.y) * physicsScale);
                    var theta:Number = 0.0;
                    
                    for (var i:int = 0; i < k_segments; ++i)
                    {
                        var d:b2Vec2 = new b2Vec2(r * Math.cos(theta), r * Math.sin(theta));
                        v = b2Math.AddVV(pos, d);
                        containerGraphics.lineTo((v.x) * physicsScale, (v.y) * physicsScale);
                        theta += k_increment;
                    }
                    containerGraphics.lineTo((pos.x + r) * physicsScale, (pos.y) * physicsScale);
                    containerGraphics.moveTo((pos.x) * physicsScale, (pos.y) * physicsScale);
                    var ax:b2Vec2 = circleShape.GetBody().GetXForm().R.col1;
                    var pos2:b2Vec2 = new b2Vec2(pos.x + r * ax.x, pos.y + r * ax.y);
                    containerGraphics.lineTo((pos2.x) * physicsScale, (pos2.y) * physicsScale);
                    break;
                }
                case b2Shape.e_polygonShape:
                {
                    //var poly:b2PolyShape = shape as b2PolyShape;
                    var polyShape:b2PolygonShape = shape as b2PolygonShape;
                    
                    var tV:b2Vec2 = b2Math.AddVV(polyShape.GetBody().GetPosition(),
                        b2Math.b2MulMV(polyShape.GetBody().GetXForm().R, polyShape.GetVertices()[0]));
                    
                    containerGraphics.moveTo(tV.x * physicsScale, tV.y * physicsScale);
                    
                    for (var j:int = 0; j < polyShape.GetVertexCount(); ++j)
                    {
                        v = b2Math.AddVV(polyShape.GetBody().GetPosition(),
                            b2Math.b2MulMV(polyShape.GetBody().GetXForm().R, polyShape.GetVertices()[j]));
                        containerGraphics.lineTo(v.x * physicsScale, v.y * physicsScale);
                    }
                    containerGraphics.lineTo(tV.x * physicsScale, tV.y * physicsScale);
                    break;
                }
            }
        }
		public function addComponent(component:IVisualElement):void {
			//for each (var nextVisualElement:IVisualElement in _physicsTargets)
			//{
				// add them to the physics world
				_physicsBodies.addItem(createBody(SkinnableComponent(component)));
			//}
		}
    }
}