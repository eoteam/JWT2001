package com.pentagram.instance.view.visualizer {
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.Joints.*;
	
	import Box2D.General.Input;
	
	import flash.display.*;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import spark.core.SpriteVisualElement;
	
	public class Box2DContainer extends SpriteVisualElement {
	
		//public var m_input:Input;   
		public function Box2DContainer() {
			this.addEventListener(Event.ADDED_TO_STAGE,construct);
		}
		private function construct(event:Event):void {			
			//m_input = new Input(this);  
			buildWalls();
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		protected function buildWalls():void {
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-1000.0, -1000.0);
			worldAABB.upperBound.Set(1000.0, 1000.0);
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			m_world = new b2World(gravity, doSleep);
			//m_world.SetBroadPhase(new b2BroadPhase(worldAABB));
			m_world.SetWarmStarting(true);
			// set debug draw
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			//var dbgSprite:Sprite = new Sprite();
			//m_sprite.addChild(dbgSprite);
			dbgDraw.SetSprite(this);
			dbgDraw.SetDrawScale(30.0);
			dbgDraw.SetFillAlpha(0.3);
			dbgDraw.SetLineThickness(1.0);
			dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			m_world.SetDebugDraw(dbgDraw);
			
			// Create border of boxes
			var wall:b2PolygonShape= new b2PolygonShape();
			var wallBd:b2BodyDef = new b2BodyDef();
			var wallB:b2Body;
			
			// Left
			wallBd.position.Set( -95 / m_physScale, 360 / m_physScale / 2);
			wall.SetAsBox(100/m_physScale, 400/m_physScale/2);
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixture2(wall);
			// Right
			wallBd.position.Set((640 + 95) / m_physScale, 360 / m_physScale / 2);
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixture2(wall);
			// Top
			wallBd.position.Set(640 / m_physScale / 2, -95 / m_physScale);
			wall.SetAsBox(680/m_physScale/2, 100/m_physScale);
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixture2(wall);
			// Bottom
			wallBd.position.Set(640 / m_physScale / 2, (360 + 95) / m_physScale);
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixture2(wall);
		}
		protected function buildParticles():void {
			var bd:b2BodyDef;
			var body:b2Body;
			var i:int;
			var x:Number;
			
			{
				var cd1:b2CircleShape = new b2CircleShape();
				cd1.SetRadius(15.0/m_physScale);
				cd1.SetLocalPosition(new b2Vec2( -15.0 / m_physScale, 15.0 / m_physScale));
				
				var cd2:b2CircleShape = new b2CircleShape();
				cd2.SetRadius(15.0/m_physScale);
				cd2.SetLocalPosition(new b2Vec2(15.0 / m_physScale, 15.0 / m_physScale));
				
				bd = new b2BodyDef();
				bd.type = b2Body.b2_dynamicBody;
				
				for (i = 0; i < 5; ++i)
				{
					x = 320.0 + b2Math.RandomRange(-3.0, 3.0);
					bd.position.Set((x + 150.0)/m_physScale, (31.5 + 75.0 * -i + 300.0)/m_physScale);
					bd.angle = b2Math.RandomRange(-Math.PI, Math.PI);
					body = m_world.CreateBody(bd);
					body.CreateFixture2(cd1, 2.0);
					body.CreateFixture2(cd2, 0.0);
				}
			}
			
			{
				var pd1:b2PolygonShape = new b2PolygonShape();
				pd1.SetAsBox(7.5/m_physScale, 15.0/m_physScale);
				
				var pd2:b2PolygonShape = new b2PolygonShape();
				pd2.SetAsOrientedBox(7.5/m_physScale, 15.0/m_physScale, new b2Vec2(0.0, -15.0/m_physScale), 0.5 * Math.PI);
				
				bd = new b2BodyDef();
				bd.type = b2Body.b2_dynamicBody;
				
				for (i = 0; i < 5; ++i)
				{
					x = 320.0 + b2Math.RandomRange(-3.0, 3.0);
					bd.position.Set((x - 150.0)/m_physScale, (31.5 + 75.0 * -i + 300)/m_physScale);
					bd.angle = b2Math.RandomRange(-Math.PI, Math.PI);
					body = m_world.CreateBody(bd);
					body.CreateFixture2(pd1, 2.0);
					body.CreateFixture2(pd2, 2.0);
				}
			}
			
			{
				var xf1:b2Transform = new b2Transform();
				xf1.R.Set(0.3524 * Math.PI);
				xf1.position = b2Math.MulMV(xf1.R, new b2Vec2(1.0, 0.0));
				
				var sd1:b2PolygonShape = new b2PolygonShape();
				sd1.SetAsArray([
					b2Math.MulX(xf1, new b2Vec2(-30.0/m_physScale, 0.0)),
					b2Math.MulX(xf1, new b2Vec2(30.0/m_physScale, 0.0)),
					b2Math.MulX(xf1, new b2Vec2(0.0, 15.0 / m_physScale)),
				]);
				
				var xf2:b2Transform = new b2Transform();
				xf2.R.Set(-0.3524 * Math.PI);
				xf2.position = b2Math.MulMV(xf2.R, new b2Vec2(-30.0/m_physScale, 0.0));
				
				var sd2:b2PolygonShape = new b2PolygonShape();
				sd2.SetAsArray([
					b2Math.MulX(xf2, new b2Vec2(-30.0/m_physScale, 0.0)),
					b2Math.MulX(xf2, new b2Vec2(30.0/m_physScale, 0.0)),
					b2Math.MulX(xf2, new b2Vec2(0.0, 15.0 / m_physScale)),
				]);
				
				bd = new b2BodyDef();
				bd.type = b2Body.b2_dynamicBody;
				bd.fixedRotation = true;
				
				for (i = 0; i < 5; ++i)
				{
					x = 320.0 + b2Math.RandomRange(-3.0, 3.0);
					bd.position.Set(x/m_physScale, (-61.5 + 55.0 * -i + 300)/m_physScale);
					bd.angle = 0.0;
					body = m_world.CreateBody(bd);
					body.CreateFixture2(sd1, 2.0);
					body.CreateFixture2(sd2, 2.0);
				}
			}
			
			{
				var sd_bottom:b2PolygonShape = new b2PolygonShape();
				sd_bottom.SetAsBox( 45.0/m_physScale, 4.5/m_physScale );
				
				var sd_left:b2PolygonShape = new b2PolygonShape();
				sd_left.SetAsOrientedBox(4.5/m_physScale, 81.0/m_physScale, new b2Vec2(-43.5/m_physScale, -70.5/m_physScale), -0.2);
				
				var sd_right:b2PolygonShape = new b2PolygonShape();
				sd_right.SetAsOrientedBox(4.5/m_physScale, 81.0/m_physScale, new b2Vec2(43.5/m_physScale, -70.5/m_physScale), 0.2);
				
				bd = new b2BodyDef();
				bd.type = b2Body.b2_dynamicBody;
				bd.position.Set( 320.0/m_physScale, 300.0/m_physScale );
				body = m_world.CreateBody(bd);
				body.CreateFixture2(sd_bottom, 4.0);
				body.CreateFixture2(sd_left, 4.0);
				body.CreateFixture2(sd_right, 4.0);
			}
		}
		public function update(e:Event):void{
			// clear for rendering
			this.graphics.clear()
			
			updatePhysics();

			// Update input (last)
			//Input.update();

		}		
		public function updatePhysics():void {
			// Update mouse joint
			UpdateMouseWorld()
			MouseDestroy();
			MouseDrag();
			
			// Update physics
			var physStart:uint = getTimer();
			m_world.Step(m_timeStep, m_velocityIterations, m_positionIterations);
			m_world.ClearForces();

			// Render
			m_world.DrawDebugData();

			
		}		
		//======================
		// Member Data 
		//======================
		public var m_world:b2World;
		public var m_bomb:b2Body;
		public var m_mouseJoint:b2MouseJoint;
		public var m_velocityIterations:int = 10;
		public var m_positionIterations:int = 10;
		public var m_timeStep:Number = 1.0/30.0;
		public var m_physScale:Number = 30;
		// world mouse position
		public var mouseXWorldPhys:Number;
		public var mouseYWorldPhys:Number;
		public var mouseXWorld:Number;
		public var mouseYWorld:Number;

		
		
		//======================
		// Update mouseWorld
		//======================
//		public function UpdateMouseWorld():void{
//			mouseXWorldPhys = (Input.mouseX)/m_physScale; 
//			mouseYWorldPhys = (Input.mouseY)/m_physScale; 
//			
//			mouseXWorld = (Input.mouseX); 
//			mouseYWorld = (Input.mouseY); 
//		}
		
		
		
		//======================
		// Mouse Drag 
		//======================
//		public function MouseDrag():void{
//			// mouse press
//			if (Input.mouseDown && !m_mouseJoint){
//				
//				var body:b2Body = GetBodyAtMouse();
//				
//				if (body)
//				{
//					var md:b2MouseJointDef = new b2MouseJointDef();
//					md.bodyA = m_world.GetGroundBody();
//					md.bodyB = body;
//					md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
//					md.collideConnected = true;
//					md.maxForce = 300.0 * body.GetMass();
//					m_mouseJoint = m_world.CreateJoint(md) as b2MouseJoint;
//					body.SetAwake(true);
//				}
//			}
//			
//			
//			// mouse release
//			if (!Input.mouseDown){
//				if (m_mouseJoint)
//				{
//					m_world.DestroyJoint(m_mouseJoint);
//					m_mouseJoint = null;
//				}
//			}
//			
//			
//			// mouse move
//			if (m_mouseJoint)
//			{
//				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
//				m_mouseJoint.SetTarget(p2);
//			}
//		}
		
		
		
		//======================
		// Mouse Destroy
		//======================
//		public function MouseDestroy():void{
//			// mouse press
//			if (!Input.mouseDown && Input.isKeyPressed(68/*D*/)){
//				
//				var body:b2Body = GetBodyAtMouse(true);
//				
//				if (body)
//				{
//					m_world.DestroyBody(body);
//					return;
//				}
//			}
//		}
	
		//======================
		// GetBodyAtMouse
		//======================
		private var mousePVec:b2Vec2 = new b2Vec2();
		public function GetBodyAtMouse(includeStatic:Boolean = false):b2Body {
			// Make a small box.
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			var body:b2Body = null;
			var fixture:b2Fixture;
			
			// Query the world for overlapping shapes.
			function GetBodyCallback(fixture:b2Fixture):Boolean
			{
				var shape:b2Shape = fixture.GetShape();
				if (fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic)
				{
					var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(), mousePVec);
					if (inside)
					{
						body = fixture.GetBody();
						return false;
					}
				}
				return true;
			}
			m_world.QueryAABB(GetBodyCallback, aabb);
			return body;
		}
	}
}
