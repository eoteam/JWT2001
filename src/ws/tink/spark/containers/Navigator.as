/*

Copyright (c) 2010 Tink Ltd - http://www.tink.ws

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

package ws.tink.spark.containers
{
	import mx.core.ContainerCreationPolicy;
	import mx.core.IDeferredContentOwner;
	import mx.core.IDeferredInstance;
	import mx.core.IFlexModuleFactory;
	import mx.core.ISelectableList;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.utils.BitFlagUtil;
	
	import spark.components.supportClasses.SkinnableContainerBase;
	import spark.events.ElementExistenceEvent;
	import spark.layouts.supportClasses.LayoutBase;
	
	import ws.tink.spark.layouts.supportClasses.INavigatorLayout;
	import ws.tink.spark.supportClasses.INavigator;
	
	use namespace mx_internal;
	
	/**
	 *  Dispatched after the content for this component has been created. With deferred 
	 *  instantiation, the content for a component may be created long after the 
	 *  component is created.
	 *
	 *  @eventType mx.events.FlexEvent.CONTENT_CREATION_COMPLETE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="contentCreationComplete", type="mx.events.FlexEvent")]
	
	/**
	 *  Dispatched when a visual element is added to the content holder.
	 *  <code>event.element</code> is the visual element that was added.
	 *
	 *  @eventType spark.events.ElementExistenceEvent.ELEMENT_ADD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="elementAdd", type="spark.events.ElementExistenceEvent")]
	
	/**
	 *  Dispatched when a visual element is removed from the content holder.
	 *  <code>event.element</code> is the visual element that's being removed.
	 *
	 *  @eventType spark.events.ElementExistenceEvent.ELEMENT_REMOVE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="elementRemove", type="spark.events.ElementExistenceEvent")]
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when the ISelectableList has been updated in some way.
	 *
	 *  @eventType mx.events.CollectionEvent.COLLECTION_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Event(name="collectionChange", type="mx.events.CollectionEvent")]
	
	/**
	 *  Dispatched after the selection has changed. 
	 *  This event is dispatched when the user interacts with the control.
	 * 
	 *  <p>When you change the value of the <code>selectedIndex</code> 
	 *  or <code>selectedItem</code> properties programmatically, 
	 *  the control does not dispatch the <code>change</code> event. 
	 *  It dispatches the <code>valueCommit</code> event instead.</p>
	 *
	 *  @eventType spark.events.IndexChangeEvent.CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="change", type="spark.events.IndexChangeEvent")]
	
//	include "../styles/metadata/BasicInheritingTextStyles.as"
//	include "../styles/metadata/AdvancedInheritingTextStyles.as"
//	include "../styles/metadata/SelectionFormatTextStyles.as"
	
	/**
	 *  @copy spark.components.supportClasses.GroupBase#style:accentColor
	 * 
	 *  @default #0099FF
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="accentColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  Alpha level of the background for this component.
	 *  Valid values range from 0.0 to 1.0. 
	 *  
	 *  @default 1.0
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="backgroundAlpha", type="Number", inherit="no", theme="spark")]
	
	/**
	 *  Background color of a component.
	 *  
	 *  @default 0xFFFFFF
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no", theme="spark")]
	
	/**
	 *  The alpha of the content background for this component.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark")]
	
	/**
	 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 * @copy spark.components.supportClasses.GroupBase#style:rollOverColor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="rollOverColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	
//	[IconFile("SkinnableContainer.png")]
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------
	
	[DefaultProperty("mxmlContentFactory")]
	
	/**
	 *  The SkinnableContainer class is the base class for skinnable containers that have 
	 *  visual content.
	 *  The SkinnableContainer container takes as children any components that implement 
	 *  the IVisualElement interface. 
	 *  All Spark and Halo components implement the IVisualElement interface, as does
	 *  the GraphicElement class. 
	 *  That means the container can use the graphics classes, such as Rect and Ellipse, as children.
	 *
	 *  <p>To improve performance and minimize application size, 
	 *  you can use the Group container. The Group container cannot be skinned.</p>
	 *
	 *  <p>The SkinnableContainer container has the following default characteristics:</p>
	 *  <table class="innertable">
	 *     <tr><th>Characteristic</th><th>Description</th></tr>
	 *     <tr><td>Default size</td><td>Large enough to display its children</td></tr>
	 *     <tr><td>Minimum size</td><td>0 pixels</td></tr>
	 *     <tr><td>Maximum size</td><td>10000 pixels wide and 10000 pixels high</td></tr>
	 *  </table>
	 * 
	 *  @mxml
	 *
	 *  <p>The <code>&lt;s:SkinnableContainer&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;s:SkinnableContainer
	 *    <strong>Properties</strong>
	 *    autoLayout="true"
	 *    creationPolicy="auto"
	 *    horizontalScrollPosition="null"
	 *    layout="BasicLayout"
	 *  
	 *    <strong>Styles</strong>
	 *    accentColor="0x0099FF"
	 *    alignmentBaseline="useDominantBaseline"
	 *    alternatingItemColors=""
	 *    backgroundAlpha="1.0"
	 *    backgroundColor="0xFFFFFF"
	 *    baselineShift="0.0"
	 *    blockProgression="TB"
	 *    breakOpportunity="auto"
	 *    cffHinting="horizontal_stem"
	 *    color="0"
	 *    contentBackgroundAlpha=""
	 *    contentBackgroundColor=""
	 *    digitCase="default"
	 *    digitWidth="default"
	 *    direction="LTR"
	 *    dominantBaseline="auto"
	 *    firstBaselineOffset="auto"
	 *    focusColor=""
	 *    focusedTextSelectionColor=""
	 *    fontFamily="Times New Roman"
	 *    fontLookup="device"
	 *    fontSize="12"
	 *    fontStyle="normal"
	 *    fontWeight="normal"
	 *    inactiveTextSelectionColor="0xE8E8E8"
	 *    justificationRule="auto"
	 *    justificationStyle="auto"
	 *    kerning="auto"
	 *    leadingModel="auto"
	 *    ligatureLevel="common"
	 *    lineHeight="120%"
	 *    lineThrough="false"
	 *    locale="en"
	 *    paragraphEndIndent="0"
	 *    paragraphSpaceAfter="0"
	 *    paragraphSpaceBefore="0"
	 *    paragraphStartIndent="0"
	 *    renderingMode="CFF"
	 *    rollOverColor=""
	 *    symbolColor=""
	 *    tabStops="null"
	 *    textAlign="start"
	 *    textAlignLast="start"
	 *    textAlpha="1"
	 *    textDecoration="none"
	 *    textIndent="0"
	 *    textJustify="inter_word"
	 *    textRotation="auto"
	 *    trackingLeft="0"
	 *    trackingRight="0"
	 *    typographicCase="default"
	 *    unfocusedTextSelectionColor=""
	 *    verticalScrollPolicy="auto"
	 *    whiteSpaceCollapse="collapse"
	 *  
	 *    <strong>Events</strong>
	 *    elementAdd="<i>No default</i>"
	 *    elementRemove="<i>No default</i>"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @see SkinnableDataContainer
	 *  @see Group
	 *  @see spark.skins.spark.SkinnableContainerSkin
	 *
	 *  @includeExample examples/SkinnableContainerExample.mxml
	 *  @includeExample examples/MyBorderSkin.mxml -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class Navigator extends SkinnableContainerBase 
		implements IDeferredContentOwner, IVisualElementContainer, INavigator
	{

		
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static const AUTO_LAYOUT_PROPERTY_FLAG:uint = 1 << 0;
		
		/**
		 *  @private
		 */
		private static const LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function Navigator()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 *  An optional skin part that defines the Group where the content 
		 *  children get pushed into and laid out.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var contentGroup:NavigatorGroup;
		
		/**
		 *  @private
		 *  Several properties are proxied to contentGroup.  However, when contentGroup
		 *  is not around, we need to store values set on SkinnableContainer.  This object 
		 *  stores those values.  If contentGroup is around, the values are stored 
		 *  on the contentGroup directly.  However, we need to know what values 
		 *  have been set by the developer on the SkinnableContainer (versus set on 
		 *  the contentGroup or defaults of the contentGroup) as those are values 
		 *  we want to carry around if the contentGroup changes (via a new skin). 
		 *  In order to store this info effeciently, contentGroupProperties becomes 
		 *  a uint to store a series of BitFlags.  These bits represent whether a 
		 *  property has been explicitely set on this SkinnableContainer.  When the 
		 *  contentGroup is not around, contentGroupProperties is a typeless 
		 *  object to store these proxied properties.  When contentGroup is around,
		 *  contentGroupProperties stores booleans as to whether these properties 
		 *  have been explicitely set or not.
		 */
		private var contentGroupProperties:Object = {};
		
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties 
		//
		//--------------------------------------------------------------------------
		
		
		//----------------------------------
		//  selectedIndex
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for selectedIndex.
		 */
		private var _selectedIndex		: int = -1;
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#selectedIndex
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set selectedIndex( value:int ):void
		{
			_selectedIndex = value;
			
			if( contentGroup ) contentGroup.selectedIndex = value;
		}
		/**
		 *  @private
		 */
		public function get selectedIndex():int
		{
			return ( contentGroup ) ? contentGroup.selectedIndex : _selectedIndex;
		}
		
		
		//----------------------------------
		//  selectedItem
		//---------------------------------- 
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#selectedItem
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get selectedItem():IVisualElement
		{
			var index:int = selectedIndex;
			return index != -1 ? getElementAt( index ) : null;
		}
		/**
		 *  @private
		 */
		public function set selectedItem( value:IVisualElement ):void
		{
			var index:int = getElementIndex( value );
			if( index != -1 ) selectedIndex = index;
		}
		
		
		//----------------------------------
		//  length
		//---------------------------------- 
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#length
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get length():int
		{
			return currentContentGroup.length;
		}
		
		
		//----------------------------------
		//  currentContentGroup
		//----------------------------------
		
		// Used to hold the content until the contentGroup is created. 
		private var _placeHolderGroup:NavigatorGroup;
		
		mx_internal function get currentContentGroup():NavigatorGroup
		{          
			createContentIfNeeded();
			
			if (!contentGroup)
			{
				if (!_placeHolderGroup)
				{
					_placeHolderGroup = new NavigatorGroup();
					
//					if (_mxmlContent)
//					{
//						_placeHolderGroup.mxmlContent = _mxmlContent;
//						_mxmlContent = null;
//					}
					
					_placeHolderGroup.addEventListener( ElementExistenceEvent.ELEMENT_ADD, onContentGroupElementAdded );
					_placeHolderGroup.addEventListener( ElementExistenceEvent.ELEMENT_REMOVE, onContentGroupElementRemoved );
				}
				return _placeHolderGroup;
			}
			else
			{
				return contentGroup;    
			}
		}
		
		
		//----------------------------------
		//  creationPolicy
		//----------------------------------
		
		// Internal flag used when creationPolicy="none".
		// When set, the value of the backing store _creationPolicy
		// style is "auto" so descendants inherit the correct value.
		private var creationPolicyNone:Boolean = false;
		
		[Inspectable(enumeration="auto,all,none", defaultValue="auto")]
		/**
		 *  @inheritDoc
		 *
		 *  @default auto
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get creationPolicy():String
		{
			// Use an inheriting style as the backing storage for this property.
			// This allows the property to be inherited by either mx or spark
			// containers, and also to correctly cascade through containers that
			// don't have this property (ie Group).
			// This style is an implementation detail and should be considered
			// private. Do not set it from CSS.
			var result:String = getStyle("_creationPolicy");
			
			if (result == null)
				result = ContainerCreationPolicy.AUTO;
			
			if (creationPolicyNone)
				result = ContainerCreationPolicy.NONE;
			
			return result;
		}
		/**
		 *  @private
		 */
		public function set creationPolicy(value:String):void
		{
			if (value == ContainerCreationPolicy.NONE)
			{
				// creationPolicy of none is not inherited by descendants.
				// In this case, set the style to "auto" and set a local
				// flag for subsequent access to the creationPolicy property.
				creationPolicyNone = true;
				value = ContainerCreationPolicy.AUTO;
			}
			else
			{
				creationPolicyNone = false;
			}
			
			setStyle("_creationPolicy", value);
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Properties 
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  moduleFactory
		//----------------------------------
		/**
		 *  @private
		 */
		override public function set moduleFactory(moduleFactory:IFlexModuleFactory):void
		{
			super.moduleFactory = moduleFactory;
			
			// Register the _creationPolicy style as inheriting. See the creationPolicy
			// getter for details on usage of this style.
			styleManager.registerInheritingStyle("_creationPolicy");
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties proxied to contentGroup
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  autoLayout
		//----------------------------------
		
		[Inspectable(defaultValue="true")]
		
		/**
		 *  @copy spark.components.supportClasses.GroupBase#autoLayout
		 *
		 *  @default true
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get autoLayout():Boolean
		{
			if (contentGroup)
				return contentGroup.autoLayout;
			else
			{
				// want the default to be true
				var v:* = contentGroupProperties.autoLayout;
				return (v === undefined) ? true : v;
			}
		}
		
		/**
		 *  @private
		 */
		public function set autoLayout(value:Boolean):void
		{
			if (contentGroup)
			{
				contentGroup.autoLayout = value;
				contentGroupProperties = BitFlagUtil.update(contentGroupProperties as uint, 
					AUTO_LAYOUT_PROPERTY_FLAG, true);
			}
			else
				contentGroupProperties.autoLayout = value;
		}
		
		
		//----------------------------------
		//  layout
		//----------------------------------
		
		/**
		 *  @copy spark.components.supportClasses.GroupBase#layout
		 *
		 *  @default BasicLayout
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get layout():INavigatorLayout
		{
			return ( contentGroup ) ? INavigatorLayout( contentGroup.layout ) 
				: INavigatorLayout( contentGroupProperties.layout );
		}
		/**
		 *  @private
		 */
		public function set layout( value:INavigatorLayout ):void
		{
			if ( contentGroup )
			{
				contentGroup.layout = value as LayoutBase;
				contentGroupProperties = BitFlagUtil.update(contentGroupProperties as uint, 
					LAYOUT_PROPERTY_FLAG, true);
			}
			else
			{
				contentGroupProperties.layout = value;
			}
		}
		
		
		//----------------------------------
		//  mxmlContent
		//----------------------------------    
		
		/**
		 *  @private
		 *  Variable used to store the mxmlContent when the contentGroup is 
		 *  not around, and there hasnt' been a need yet for the placeHolderGroup.
		 */
//		private var _mxmlContent:Array;
		
		/**
		 *  @private
		 *  Variable that represents whether the content has been explicitely set 
		 *  (via mxmlContent setter or with the mutation APIs, like addElement).  
		 *  This is used to figure out whether we should override the default "content"
		 *  that is in the contentGroup of a skin.
		 */
		private var _contentModified:Boolean = false;
		
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  @copy spark.components.Group#mxmlContent
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set mxmlContent(value:Array):void
		{
//			if (contentGroup)
//				contentGroup.mxmlContent = value;
//			else if (_placeHolderGroup)
//				_placeHolderGroup.mxmlContent = value;
//			else
//				_mxmlContent = value;
			
			currentContentGroup.mxmlContent = value;
			
			if (value != null)
				_contentModified = true;
			
//			_mxmlContent = value;
		}
		
		//----------------------------------
		//  mxmlContentFactory
		//----------------------------------
		
		/** 
		 *  @private
		 *  Backing variable for the contentFactory property.
		 */
		private var _mxmlContentFactory:IDeferredInstance;
		
		/**
		 *  @private
		 *  Flag that indicates whether or not the content has been created.
		 */
		private var mxmlContentCreated:Boolean = false;
		
		[InstanceType("Array")]
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  A factory object that creates the initial value for the
		 *  <code>content</code> property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set mxmlContentFactory(value:IDeferredInstance):void
		{
			if (value == _mxmlContentFactory)
				return;
			
			_mxmlContentFactory = value;
			mxmlContentCreated = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods proxied to contentGroup
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#addItem
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function addItem( item:Object ):void
		{
			addItemAt( item, length );
		}
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#addItemAt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function addItemAt( item:Object, index:int ):void
		{
			currentContentGroup.addItemAt( item, index );
		}
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#getItemAt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getItemAt( index:int, prefetch:int = 0 ):Object
		{
			return currentContentGroup.getItemAt( index );
		}
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#getItemIndex
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getItemIndex( item:Object ):int
		{
			return currentContentGroup.getItemIndex( item );
		}
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#itemUpdated
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function itemUpdated( item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null ):void
		{
			currentContentGroup.itemUpdated( item, property, oldValue, newValue );
		}
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#removeAll
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeAll():void
		{
			currentContentGroup.removeAll();
		}
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#removeItemAt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeItemAt( index:int ):Object
		{
			return currentContentGroup.removeItemAt( index );
		}
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#setItemAt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function setItemAt( item:Object, index:int ):Object
		{
			return currentContentGroup.setItemAt( item, index );
		}
		
		/**
		 *  @copy ws.tink.spark.containers.NavigatorGroup#toArray
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function toArray():Array
		{
			return currentContentGroup.toArray();
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get numElements():int
		{
			return currentContentGroup.numElements;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getElementAt(index:int):IVisualElement
		{
			return currentContentGroup.getElementAt(index);
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getElementIndex(element:IVisualElement):int
		{
			return currentContentGroup.getElementIndex(element);
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function addElement(element:IVisualElement):IVisualElement
		{
			_contentModified = true;
			return currentContentGroup.addElement(element);
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function addElementAt(element:IVisualElement, index:int):IVisualElement
		{
			_contentModified = true;
			return currentContentGroup.addElementAt(element, index);
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeElement(element:IVisualElement):IVisualElement
		{
			_contentModified = true;
			return currentContentGroup.removeElement(element);
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeElementAt(index:int):IVisualElement
		{
			_contentModified = true;
			return currentContentGroup.removeElementAt(index);
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeAllElements():void
		{
			_contentModified = true;
			currentContentGroup.removeAllElements();
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function setElementIndex (element:IVisualElement, index:int ):void
		{
			_contentModified = true;
			currentContentGroup.setElementIndex(element, index);
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function swapElements(element1:IVisualElement, element2:IVisualElement):void
		{
			_contentModified = true;
			
			// TODO tink swapElements
			swapElementsAt( getElementIndex( element1 ), getElementIndex( element1 ) )
			
			//currentContentGroup.swapElements(element1, element2);
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function swapElementsAt(index1:int, index2:int):void
		{
			_contentModified = true;
			currentContentGroup.swapElementsAt(index1, index2);
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  IDeferredContentOwner methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Create the content for this component. 
		 *  When the <code>creationPolicy</code> property is <code>auto</code> or
		 *  <code>all</code>, this function is called automatically by the Flex framework.
		 *  When <code>creationPolicy</code> is <code>none</code>, you call this method to initialize
		 *  the content.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function createDeferredContent():void
		{
			if (!mxmlContentCreated)
			{
				mxmlContentCreated = true;
				
				if (_mxmlContentFactory)
				{
					var deferredContent:Object = _mxmlContentFactory.getInstance();
					mxmlContent = deferredContent as Array;
					_deferredContentCreated = true;
					dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
				}
			}
		}
		
		private var _deferredContentCreated:Boolean;
		
		/**
		 *  Contains <code>true</code> if deferred content has been created.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get deferredContentCreated():Boolean
		{
			return _deferredContentCreated;
		}
		
		/**
		 *  @private
		 */
		private function createContentIfNeeded():void
		{
			if (!mxmlContentCreated && creationPolicy != ContainerCreationPolicy.NONE)
				createDeferredContent();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void
		{
			var hl:Boolean = hasEventListener( CollectionEvent.COLLECTION_CHANGE );
			
			super.addEventListener( type, listener, useCapture, priority, useWeakReference );
			
			if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) && !hl )
			{
				currentContentGroup.addEventListener( CollectionEvent.COLLECTION_CHANGE, onContentGroupCollectionChange, false, 0, true );
			}
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void
		{
			var hl:Boolean = hasEventListener( CollectionEvent.COLLECTION_CHANGE );
			
			super.removeEventListener( type, listener, useCapture );
			
			if( !hasEventListener( CollectionEvent.COLLECTION_CHANGE ) && hl )
			{
				currentContentGroup.removeEventListener( CollectionEvent.COLLECTION_CHANGE, onContentGroupCollectionChange, false );
			}
		}
		
		/**
		 *  Create content children, if the <code>creationPolicy</code> property 
		 *  is not equal to <code>none</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			// TODO (rfrishbe): When contentGroup support is added, this is where we would 
			// determine if content should be created now, or wait until
			// later. For now, we always create content here unless
			// creationPolicy="none".
			createContentIfNeeded();
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == contentGroup)
			{
				if (_contentModified)
				{
					if (_placeHolderGroup != null)
					{
						var sourceContent:Array = _placeHolderGroup.getMXMLContent();
						
						// TODO (rfrishbe): Also look at why we need a defensive copy for mxmlContent in Group, 
						// especially if we make it mx_internal.  Also look at controlBarContent.
						
						// If a child element has been addElemented() to the placeHolderGroup, 
						// then it wouldn't been added to the display list and we can't just 
						// copy the mxmlContent from the placeHolderGroup, but we must also 
						// call removeElement() on those children.
						for (var i:int = _placeHolderGroup.numElements; i > 0; i--)
						{
							_placeHolderGroup.removeElementAt(0);  
						}
						
						contentGroup.mxmlContent = sourceContent ? sourceContent.slice() : null;
						
					}
//					else if (_mxmlContent != null)
//					{
//						contentGroup.mxmlContent = _mxmlContent;
//						_mxmlContent = null;
//					}
				}
				
				// Not your typical delegation, see 'set useVirtualLayout'
//				if( _useVirtualLayout && contentGroup.layout )
//					contentGroup.layout.useVirtualLayout = true;
				
				// copy proxied values from contentGroupProperties (if set) to contentGroup
				
				var newContentGroupProperties:uint = 0;
				
				if (contentGroupProperties.autoLayout !== undefined)
				{
					contentGroup.autoLayout = contentGroupProperties.autoLayout;
					newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
						AUTO_LAYOUT_PROPERTY_FLAG, true);
				}
				
				if (contentGroupProperties.layout !== undefined)
				{
					contentGroup.layout = contentGroupProperties.layout;
					newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
						LAYOUT_PROPERTY_FLAG, true);
				}
				
				contentGroup.selectedIndex = _selectedIndex;
				
				contentGroupProperties = newContentGroupProperties;
				
				contentGroup.addEventListener( ElementExistenceEvent.ELEMENT_ADD, onContentGroupElementAdded );
				contentGroup.addEventListener( ElementExistenceEvent.ELEMENT_REMOVE, onContentGroupElementRemoved );
				if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ) contentGroup.addEventListener( CollectionEvent.COLLECTION_CHANGE, onContentGroupElementAdded );
				
				if (_placeHolderGroup)
				{
					_placeHolderGroup.removeEventListener( ElementExistenceEvent.ELEMENT_ADD, onContentGroupElementAdded );
					_placeHolderGroup.removeEventListener( ElementExistenceEvent.ELEMENT_REMOVE, onContentGroupElementRemoved );
					if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ) _placeHolderGroup.removeEventListener( CollectionEvent.COLLECTION_CHANGE, onContentGroupElementAdded );
					_placeHolderGroup = null;
				}
			}
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == contentGroup)
			{
				contentGroup.removeEventListener( ElementExistenceEvent.ELEMENT_ADD, onContentGroupElementAdded );
				contentGroup.removeEventListener( ElementExistenceEvent.ELEMENT_REMOVE, onContentGroupElementRemoved );
				if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ) contentGroup.removeEventListener( CollectionEvent.COLLECTION_CHANGE, onContentGroupCollectionChange );
				
				// copy proxied values from contentGroup (if explicitely set) to contentGroupProperties
				
				var newContentGroupProperties:Object = {};
				
				if (BitFlagUtil.isSet(contentGroupProperties as uint, AUTO_LAYOUT_PROPERTY_FLAG))
					newContentGroupProperties.autoLayout = contentGroup.autoLayout;
				
				if (BitFlagUtil.isSet(contentGroupProperties as uint, LAYOUT_PROPERTY_FLAG))
					newContentGroupProperties.layout = contentGroup.layout;
				
				contentGroupProperties = newContentGroupProperties;
				
				var myMxmlContent:Array = contentGroup.getMXMLContent();
				
				if (_contentModified && myMxmlContent)
				{
					_placeHolderGroup = new NavigatorGroup();
					
					_placeHolderGroup.mxmlContent = myMxmlContent;
					
					_placeHolderGroup.addEventListener( ElementExistenceEvent.ELEMENT_ADD, onContentGroupElementAdded );
					_placeHolderGroup.addEventListener( ElementExistenceEvent.ELEMENT_REMOVE, onContentGroupElementRemoved );
					if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ) _placeHolderGroup.addEventListener( CollectionEvent.COLLECTION_CHANGE, onContentGroupCollectionChange );
				}
				
				contentGroup.mxmlContent = null;
				contentGroup.layout = null;
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event Listeners
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function onContentGroupElementAdded( event:ElementExistenceEvent ):void
		{
			event.element.owner = this
			dispatchEvent( event );
		}
		
		/**
		 *  @private
		 */
		private function onContentGroupElementRemoved( event:ElementExistenceEvent ):void
		{
			event.element.owner = null;
			dispatchEvent( event );
		}
		
		/**
		 *  @private
		 */
		private function onContentGroupCollectionChange( event:CollectionEvent ):void
		{
			dispatchEvent( event );
		}
		
	}
	
}
