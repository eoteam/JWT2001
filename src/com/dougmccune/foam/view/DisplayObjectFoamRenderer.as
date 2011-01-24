package com.dougmccune.foam.view
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.view.IFoamRenderer;
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.view.SimpleFoamRenderer;

	public class DisplayObjectFoamRenderer extends SimpleFoamRenderer implements IFoamRenderer
	{
		/**
		 * We need to override setupRenderDataDefaults because the SimpleFoamRenderer assumes we're passing in 
		 * a Renderable object that has a data property that has a few specific properties, like color, alpha, and hash.
		 * Since we're actually going to pass in a DisplayObject, we can't let super.setupRenderDataDefaults run.
		 */
		override protected function setupRenderDataDefaults( renderable:Renderable ) : void
		{
			
		}
		
		override public function redraw():void
		{
			for each( var renderable:Renderable in _dynamicRenderables )
			{
				if(renderable.data is DisplayObject) {
				
					var displayObject:DisplayObject = (renderable.data as DisplayObject);
					
					if( renderable.element is ISimulatable )
					{
						displayObject.x = ISimulatable( renderable.element ).x;
						displayObject.y = ISimulatable( renderable.element ).y;
						
						if( renderable.element is IBody ) {
							displayObject.rotation = IBody( renderable.element ).q * 180 / Math.PI;
						}
					}
				}
			}
		}
	}
}