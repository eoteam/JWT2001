package  fxgparser
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import fxgparser.parser.FxgFactory;
	
	import spark.core.SpriteVisualElement;
	
	public class FxgDisplay extends Sprite{
		
		private var _factory:FxgFactory;
		
		public function FxgDisplay() 
		{ 
			
		}
		
		public function parse( xml:XML ):void 
		{
			_factory = new FxgFactory();
			_factory.addEventListener( Event.COMPLETE, onComplete );
			_factory.parse(  xml  , this );
		}
		
		private function onComplete( e:Event ):void
		{
			dispatchEvent( e );
		}
		
	}
	
}