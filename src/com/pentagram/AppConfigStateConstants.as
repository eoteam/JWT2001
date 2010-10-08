/*
* Robotlegs Chat Client Example using WebORB (authentication) and the Union Platform
* for client communicaton.
* 	
* Copyright (c) 2009 the original author or authors
*
* http://creativecommons.org/licenses/by-sa/3.0/
*	
* original author:
* Joel Hooks
* http://joelhooks.com
* joelhooks@gmail.com 
*/
package com.pentagram
{
	/**
	 * Static constants and variables used for configuring the Finite State
	 * Machine used by this example for application bootstrapping.
	 *  
	 * @author joel
	 * 
	 */	
	public class AppConfigStateConstants
	{
		public static const STARTING:String              		= "state/starting";
		public static const START:String                 		= "event/start";
		public static const STARTED:String               		= "action/completed/start";
		public static const START_FAILED:String          		= "action/start/failed";
		
		public static const CONFIGURING_SERVICES:String         = "state/configuring/services";
		public static const CONFIGURE_SERVICES:String           = "event/configure/services";
		public static const CONFIGURE_SERVICES_COMPLETE:String  = "action/configure/services/complete";
		public static const CONFIGURE_SERVICES_FAILED:String   	= "action/configure/services/failed";

		public static const CONFIGURING_MODELS:String          	= "state/configuring/models";
		public static const CONFIGURE_MODELS:String             = "event/configure/models";
		public static const CONFIGURE_MODELS_COMPLETE:String    = "action/configure/models/complete";
		public static const CONFIGURE_MODELS_FAILED:String   	= "action/configure/models/failed";

		public static const CONFIGURING_COMMANDS:String         = "state/configuring/commands";
		public static const CONFIGURE_COMMANDS:String           = "event/configure/commands";
		public static const CONFIGURE_COMMANDS_COMPLETE:String  = "action/configure/commands/complete";
		public static const CONFIGURE_COMMANDS_FAILED:String    = "action/configure/commands/failed";

		public static const CONFIGURING_VIEWS:String            = "state/configuring/views";
		public static const CONFIGURE_VIEWS:String              = "event/configure/views";
		public static const CONFIGURE_VIEWS_COMPLETE:String     = "action/configure/views/complete";
		public static const CONFIGURE_VIEWS_FAILED:String   	= "action/configure/views/failed";

		public static const DISPLAYING_APPLICATION:String		="state/displayingApplication";
		public static const DISPLAY_APPLICATION:String			="event/displayApplication";
		
		public static const FAILING:String  	  		  	    = "state/failing";
		public static const FAIL:String  	  		  	        = "event/fail";

		/**
		 * XML configures the State Machine. This could be loaded from an external
		 * file as well. 
		 */		
		public static const FSM:XML = 
			<fsm initial={STARTING}>
			    
			    <!-- THE INITIAL STATE -->
				<state name={STARTING}>

			       <transition action={STARTED} 
			       			   target={CONFIGURING_COMMANDS}/>

			       <transition action={START_FAILED} 
			       			   target={FAILING}/>
				</state>
				
				<!-- DOING SOME WORK -->
				<state name={CONFIGURING_COMMANDS} changed={CONFIGURE_COMMANDS}>

			       <transition action={CONFIGURE_COMMANDS_COMPLETE} 
			       			   target={CONFIGURING_SERVICES}/>
			       
			       <transition action={CONFIGURE_COMMANDS_FAILED} 
			       			   target={FAILING}/>

				</state>

				<state name={CONFIGURING_SERVICES} changed={CONFIGURE_SERVICES}>

			       <transition action={CONFIGURE_SERVICES_COMPLETE} 
			       			   target={CONFIGURING_MODELS}/>
			       
			       <transition action={CONFIGURE_SERVICES_FAILED} 
			       			   target={FAILING}/>

				</state>

				<state name={CONFIGURING_MODELS} changed={CONFIGURE_MODELS}>

			       <transition action={CONFIGURE_MODELS_COMPLETE} 
			       			   target={CONFIGURING_VIEWS}/>
			       
			       <transition action={CONFIGURE_MODELS_FAILED} 
			       			   target={FAILING}/>

				</state>

				<state name={CONFIGURING_VIEWS} changed={CONFIGURE_VIEWS}>

			       <transition action={CONFIGURE_VIEWS_COMPLETE} 
			       			   target={DISPLAYING_APPLICATION}/>
			       
			       <transition action={CONFIGURE_VIEWS_FAILED} 
			       			   target={FAILING}/>

				</state>
								
				<!-- READY TO ACCEPT BROWSER OR USER NAVIGATION -->
				<state name={DISPLAYING_APPLICATION} changed={DISPLAY_APPLICATION}/>
				
				<!-- REPORT FAILURE FROM ANY STATE -->
				<state name={FAILING} changed={FAIL}/>

			</fsm>;
	}
}