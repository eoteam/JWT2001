package com.pentagram.instance.view.visualizer
{
    import Box2D.Collision.Shapes.b2PolygonDef;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.Joints.b2Joint;
    import Box2D.Dynamics.Joints.b2MouseJoint;
    import Box2D.Dynamics.Joints.b2MouseJointDef;
    import Box2D.Dynamics.Joints.b2PulleyJoint;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2World;
    
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    
    import spark.components.SkinnableContainer;
    import spark.components.supportClasses.SkinnableComponent;
    
    public class PhysicsMapping
    {
        private var _mouseJoint:b2MouseJoint = null;
        
        
        /**
         * Constructor
         */
        public function PhysicsMapping(actualTargetArg:SkinnableComponent, worldArg:b2World)
        {
            trace("PhysicsMapping(" + actualTargetArg.id + ", " + worldArg + ")");
            actualTarget = actualTargetArg;
            world = worldArg;
            
            // create the body to match the actual target
            _physicsTarget = createBody();
        }
        
        
        
        private function createBody():b2Body
        {
            trace("PhysicsMapping.createBody()");
            var bodyDef:b2BodyDef = new b2BodyDef();
            //bodyDef.position.Set(actualTarget.x + (actualTarget.width/2), actualTarget.y + (actualTarget.height/2));
            bodyDef.position.Set(actualTarget.x, actualTarget.y);
            
            var body:b2Body = world.CreateBody(bodyDef);
            
            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(actualTarget.x, actualTarget.y);
            // density is used in the collisions equation to be density*area=mass
            // a density of 0 or null will make the object static, never moving in the case of a collision or gravity
            boxDef.density = 10.0;
            // friction is used to calculate the friction between two objects; it should be between 0.0 and 1.0
            boxDef.friction = 0.5;
            // restitution is the bounciness of the object; it should be between 0.0 and 1.0
            boxDef.restitution = 0.2;
            
            body.CreateShape(boxDef);
            body.SetMassFromShapes();
            
            return body;
        }
        
        
        
        /**
         * Applies results of physics movement to the actualTarget so the movement is visible to the
         * real world.
         */
        public function updateActual():void
        {
            //trace("PhysicsMapping.updateActual()");
            actualTarget.x = physicsTarget.GetPosition().x;
            actualTarget.y = physicsTarget.GetPosition().y;
            actualTarget.rotation = physicsTarget.GetAngle() * 180 / Math.PI;
        }
        
        
        
        private var _enabled:Boolean = false;
        public function get enabled():Boolean
        {
            return _enabled;
        }
        public function set enabled(value:Boolean):void
        {
            if (_enabled != value)
            {
                _enabled = value;
            }
        }
        
        
        
        private var _actualTarget:SkinnableComponent = null;
        public function get actualTarget():SkinnableComponent
        {
            return _actualTarget;
        }
        public function set actualTarget(value:SkinnableComponent):void
        {
            if (_actualTarget != value)
            {
                _actualTarget = value;
            }
        }
        
        
        
        private var _world:b2World = null;
        [Bindable]
        public function get world():b2World
        {
            return _world;
        }
        public function set world(value:b2World):void
        {
            if (_world != value)
            {
                _world = value;
            }
        }
        
        
        
        private var _physicsTarget:b2Body = null;
        public function get physicsTarget():b2Body
        {
            return _physicsTarget;
        }
        public function set physicsTarget(value:b2Body):void
        {
            _physicsTarget = value;
        }
        
    }
}