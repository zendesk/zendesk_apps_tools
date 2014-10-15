## Zendesk App Tools

The Zendesk app tools (ZAT) is a collection of local development tools that simplify building and deploying Zendesk apps. The tools lets you create, test, validate, and package your apps locally.

ZAT is a [Ruby gem](http://rubygems.org/gems/zendesk_apps_tools) -- a self-contained package of Ruby code that extends Ruby. You don't need to know Ruby to use the tools but you do need to install Ruby to install the gem.

To install the tools, see [Installing and using the Zendesk apps tools](https://support.zendesk.com/entries/25079228). See the [known issues](https://support.zendesk.com/entries/42600698) if you run into any problems installing or using the tools.

The tools consist of the following commands.

### New

Creates all the files necessary to start building a Zendesk app.

    $ zat new

Example:

![image](http://cdn.zendesk.com/images/documentation/apps/zat_mac_cmd_new.png)

### Validate

Runs a suite of validation tests against your app.

    $ zat validate

### Server

Starts a local HTTP server that lets you run and test your apps locally.

Follow these steps to run an app locally: 

1. Use a command-line interface to navigate to the folder containing the app you want to test.

- Run the following command in the app's folder to start the server:

   		$ zat server

- In a browser, navigate to any ticket in Zendesk. The URL should look something like this:

	<tt>https://subdomain.zendesk.com/agent/tickets/321321</tt>

- Insert `?zat=true` at the end of the URL in the Address bar.

	The URL should now look like this:

	<tt>https://subdomain.zendesk.com/agent/tickets/321321?zat=true</tt>

- Click the Reload Apps icon in the upper-right side of the Apps panel to load your local app.	

	**Note**: If nothing happens and you're using Chrome or Firefox, click the shield icon on the Address Bar and agree to load an unsafe script (Chrome) or to disable protection on the page (Firefox).
	
To stop the server, switch to your command-line interface and press Control+C.


### Package

Creates a zip file that you can [upload and install](https://support.zendesk.com/entries/25221787) in Zendesk.

    $ zat package

The command saves the zip file in a folder named <tt>tmp</tt>.

Example:

![image](http://cdn.zendesk.com/images/documentation/apps/zat_mac_cmd_package.png)

### Clean

Removes the zip files in the <tt>tmp</tt> folder that's created when you package the app.

    $ zat clean

