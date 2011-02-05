////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.pentagram.instance.view.visualizer.renderers
{
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.charts.HitData;
	import mx.charts.chartClasses.DataTip;
	import mx.charts.chartClasses.GraphicsUtilities;
	import mx.charts.styles.HaloDefaults;
	import mx.core.IDataRenderer;
	import mx.core.IFlexModuleFactory;
	import mx.core.IUITextField;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	import mx.graphics.IFill;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.styles.CSSStyleDeclaration;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when an object's state changes from visible to invisible.
	 *
	 *  @eventType mx.events.FlexEvent.HIDE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Event(name="hide", type="mx.events.FlexEvent")]
	
	/**
	 *  Dispatched when the component becomes visible.
	 *
	 *  @eventType mx.events.FlexEvent.SHOW
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Event(name="show", type="mx.events.FlexEvent")]
	

	
	/**
	 *  Background color of the component.
	 *  You can either have a <code>backgroundColor</code>
	 *  or a <code>backgroundImage</code>, but not both.
	 *  Note that some components, like a Button, do not have a background
	 *  because they are completely filled with the button face or other graphics.
	 *  The DataGrid control also ignores this style.
	 *  The default value is <code>undefined</code>.
	 *  If both this style and the backgroundImage style are undefined,
	 *  the control has a transparent background.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	
	/**
	 *  Black section of a three-dimensional border,
	 *  or the color section of a two-dimensional border.
	 *  The following components support this style: Button, CheckBox, ComboBox,
	 *  MenuBar, NumericStepper, ProgressBar, RadioButton, ScrollBar, Slider,
	 *  and all components that support the <code>borderStyle</code> style.
	 *  The default value depends on the component class;
	 *  if not overriden for the class, it is <code>0xAAB3B3</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	
	/**
	 *  Bounding box style.
	 *  The possible values are <code>"none"</code>, <code>"solid"</code>,
	 *  <code>"inset"</code> and <code>"outset"</code>.
	 *  The default value is <code>"inset"</code>.
	 *
	 *  <p>Note: The <code>borderStyle</code> style is not supported by the
	 *  Button control or the Panel container.
	 *  To make solid border Panels, set the <code>borderThickness</code>
	 *  property, and set the <code>dropShadow</code> property to
	 *  <code>false</code> if desired.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Style(name="borderStyle", type="String", enumeration="inset,outset,solid,none", inherit="no")]
	
	/**
	 *  Number of pixels between the datatip's bottom border and its content area.
	 *  The default value is 0.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	
	/**
	 *  Number of pixels between the datatip's top border and its content area.
	 *  The default value is 0.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]
	
	/**
	 *  Bottom inside color of a button's skin.
	 *  A section of the three-dimensional border.
	 *  The default value is <code>0xEEEEEE</code> (light gray).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Style(name="shadowColor", type="uint", format="Color", inherit="yes")]
	
	/**
	 *  The DataTip control provides information
	 *  about a data point to chart users.
	 *  When a user moves their mouse over a graphical element, the DataTip
	 *  control displays text that provides information about the element.
	 *  You can use DataTip controls to guide users as they work with your
	 *  application or customize the DataTips to provide additional functionality.
	 *
	 *  <p>To enable DataTips on a chart, set its <code>showDataTips</code>
	 *  property to <code>true</code>.</p>
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class GraphDataTip extends UIComponent implements IDataRenderer
	{
		private var _hitData:HitData;
		private static const HEX_DIGITS:String = "0123456789ABCDEF";
		
		[Inspectable(environment="none")]
		public static var maxTipWidth:Number = 300;

		public function GraphDataTip()
		{
			super();	
			mouseChildren = false;
			mouseEnabled = false;
		};

		[Inspectable(environment="none")]
		public function get data():Object
		{
			return _hitData;
		}
		public function set data(value:Object):void
		{
			_hitData = HitData(value);
			if(tooltip)
				tooltip.data = _hitData;
			invalidateSize();
			invalidateDisplayList();
		}
		override protected function measure():void
		{
			super.measure();			
			measuredWidth = 240;
			measuredHeight = 105;        
		} 	
		private var tooltip:BubbleToolTip;
		override protected function createChildren():void
		{
			super.createChildren();
		    tooltip = new BubbleToolTip();
			this.addChild(tooltip);
		}		
		private function decToColor(v:Number):String
		{
			var str:String = "#";
			for (var i:int = 5; i >= 0; i--)
			{
				str += HEX_DIGITS.charAt((v >> i*4) & 0xF);
			}
			return str;
		}
	}
}
