ADOBE AIR Launchpad Beta Readme

The result of the Adobe AIR Launchpad application generation is a complete Flex project in
the form of both an expanded project folder and a compressed project zip file. To import
your project into Flash Builder, choose the File | Import Flash Builder Project option.
From there you can import either the zip file or the project folder by pointing to the
location where it was generated. You can also use the File | Import | Other | Existing
projects into Workspace option to import your project.

Once imported, your project will run out of the box with the options and samples chosen
and show the application name along with a set of tabs showing sample code options to
include, if any. The code can then be modified as needed. The samples are each stored in
the src/samples/ folder and can be copied and pasted from then removed as needed. Icons
chosen at generate time were placed in the assets/ folder.

Adobe AIR Launchpad assumes you are running at least Flex 4 SDK with AIR 2.0 overlay, but it 
is recommended that you download the Flex 4.1 SDK version it includes AIR 2.0 and has important 
fixes. The Flex 4.1 SDK can be downloaded from this URL: 
	http://opensource.adobe.com/wiki/display/flexsdk/Download+Flex+4

INSTALL BADGE GENERATION
If you chose to generate the install_badge files, they will be located in the
install_badge/ folder under the root project. You will need to update the
default_badge.html file in that folder to point to your AIR application to include:
	1) The name of your application (as in the Main-app.xml descriptor file in your root 
	project folder in the name property)
	2) The URL to the AIR file that you will export from your app via Flash Builder 4 - 
	File | Export | Release Build command such as in the following two lines (note there 
	are two places to change the URL to the AIR file):

	...'flashvars','appname=MyApp&appurl=myapp.air&airversion=1.0&imageurl=badgeImage.jpg'...
	...document.write('<table id="AIRDownloadMessageTable"><tr><td>Download <a href="myapp.air">My Application</a> 
	now...
	
	Note: You may need to put in a full path URL to your air file in the above. Also, If you did 
	not choose an image, the default badgeImage.jpg will be used. The image can be replaced or a 
	new image included and the dimensions changed as desired in the default_badge.html file. If 
	you did select an image to use for the install badge from the Adobe AIR Launchpad, it will be 
	located within the install_badge/ folder with the name of your application, followed
	by _badgeImage and the extension of the file type (for example: 'MyApp_badgeImage.jpg'). 

AUTO-UPDATE
If you chose the auto-update option, a server/ folder will be generated and placed in the
src/ folder of your project. This file will point to a URL that will need to be updated
with the final URL to where your AIR application will be accessed.

ICONS
Default icons for the dock icon and other application icons that may be used are included
in the assets folder and referred to from the generated application descriptor
(Main-app.xml). If you chose icons to use in the Adobe AIR Launchpad, those will be
automatically referred to and placed in the assets folder.

Note: if you're using Flex Builder, you can still import projects generated from Adobe AIR
Launchpad. You will just need to make the necessary changes to your project for the Flex
and AIR SDK's currently being used in your own environment. 

RESIZE SETTING ON MAC
If you choose to do minimizing and maximizing but not to do resizing from the Adobe AIR Launchpad, 
you may notice that your application will still allow you to resize if you're running on Mac. This 
issue occurs whether or not the app-descriptor.xml is generated from Adobe AIR Launchpad or not. 
To get around it you can set the maximize value to false as well and then your app should not allow 
resize either.  