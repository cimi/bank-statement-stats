# Development

Make sure you have git, node, npm and ruby installed. After forking/cloning this project, navigate the project directory and run:

````
[make sure you have ruby installed, with the compass gem available]
npm install
npm install -g grunt-cli bower
bower install
grunt debug
````

You should see it running the development server.

Open Chrome and go to `Tools > Extensions`, check Developer Mode in the top right. Click `Load unpacked extension` and point it the `app/` directory in the project. This should load up the extension and you should be able to see the page action icon in the URL bar.

Try changing popup.html it should automatically refresh the extension. After clicking the icon you should be able to see the changes you've made in the popup.
