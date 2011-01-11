package com.pentagram.instance.view.visualizer
{
    import Box2D.Collision.Shapes.b2BoxDef;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    
    import mx.core.IVisualElement;
    
    import spark.components.Button;
    import spark.components.SkinnableContainer;
    import spark.components.supportClasses.SkinnableComponent;

    public class ButtonMapping
    {
        
        private var _main:Main;
        private var _component:SkinnableComponent;
        private var _componentVisual:SkinnableContainer;
        private var _componentBody:b2Body;
        
        
        
        public function ButtonMapping(main:Main, component:Button)
        {
            this._main = main;
            this._component = component;
            init();
        }
        
        
        
        private function init():void
        {
            var componentX:Number = this._component.x;
            var componentY:Number = this._component.y;
            var componentW:Number = this._component.width;
            var componentH:Number = this._component.height;
            var componentR:Number = this._component.rotation;
            this._component.x = -componentW / 2;
            this._component.y = -componentH / 2;
            this._component.rotation = 0;
            
            this._componentVisual = new SkinnableContainer();
            this._componentVisual.x = componentX + componentW / 2;
            this._componentVisual.y = componentY + componentH / 2;
            this._componentVisual.rotation = componentR;
            this._componentVisual.addElement(this._component);
            this._main.getCanvas().addElement(this._componentVisual);
            
            var bodyDef:b2BodyDef = new b2BodyDef();
            var boxDef:b2BoxDef = new b2BoxDef();
            boxDef.extents.Set(componentW / 2, componentH / 2);
            boxDef.density = 10.0;
            boxDef.friction = 0.5;
            boxDef.restitution = 0.2;
            bodyDef.position.Set(this._componentVisual.x, this._componentVisual.y);
            bodyDef.rotation = this._componentVisual.rotation * Math.PI / 180;
            bodyDef.AddShape(boxDef);
            bodyDef.userData = this._componentVisual;
            this._componentBody = this._main.getWorld().CreateBody(bodyDef);
        }
        
        
        
        public function update():void
        {
            var componentBodyX:Number = this._componentBody.m_position.x;
            var componentBodyY:Number = this._componentBody.m_position.y;
            var componentWidth:Number = this._component.width;
            var componentHeight:Number = this._component.height;
            this._componentBody.m_userData.x = componentBodyX;
            this._componentBody.m_userData.y = componentBodyY;
            this._componentBody.m_userData.rotation = this._componentBody.m_rotation * 180 / Math.PI;
        }
        
        
        
        public function getShapeList():Array
        {
            return [this._componentBody.m_shapeList];
        }
    }
}