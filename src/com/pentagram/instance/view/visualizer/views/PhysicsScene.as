package com.pentagram.instance.view.visualizer.views
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.cove.ape.*;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;

	public class PhysicsScene extends SpriteVisualElement
	{
		protected var balls:APEGroup;
		private var walls:Walls;
		
		public var timer:Timer;
		public var engine:APEngine;
		
		public var running:Boolean = false;
		public function PhysicsScene()
		{
			engine = new APEngine();
			engine.init(1/2);
			engine.container = this;
			engine.addForce(new VectorForce(false,0, 0));//Massless
			this.addEventListener(Event.ADDED_TO_STAGE,handleAddedStage);
			//timer.addEventListener(TimerEvent.TIMER,enterFrameHandler);
		}
		public function handleAddedStage(event:Event):void {
			walls = new Walls(engine,stage.stageWidth, stage.stageHeight);
			balls = new APEGroup(engine);
			engine.addGroup(balls);
			engine.addGroup(walls); 
			balls.addCollidable ( walls );
			//balls.collideInternal=true;
			//addEventListener(Event.ENTER_FRAME, enterFrameHandler);		
			timer = new Timer(5000,1);
			timer.addEventListener(TimerEvent.TIMER,stop);
			//timer.start();
		}
		public function reset():void
		{
			balls.cleanup();
			engine.removeGroup(balls);
			for(var i:int = 0;i<this.numChildren;i++)			
			{
				this.removeChildAt(i);
			}			
			balls = new org.cove.ape.APEGroup(engine);
			engine.addGroup(balls);
			balls.collideInternal=true;
		}
		public function start():void
		{
			//timer.start();
			running = true;
			balls.collideInternal = true;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		public function stop(event:Event=null):void
		{
			//timer.stop();
			balls.collideInternal = running = false;
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		public function pause():void {
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		public function addParticle(c:CircleParticle):void {
			balls.addParticle(c);
		}
		private function enterFrameHandler(event:Event):void
		{
			if(stage) {
				engine.step();
				engine.paint();
				walls.update(stage.stageWidth, stage.stageHeight);
			}
			else
				stop();
		}                 
	}
}