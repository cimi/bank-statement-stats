# Development

Make sure you have git, node, npm and ruby installed. After forking/cloning this project, navigate the project directory and run:

````
gem install compass
npm install
npm install -g grunt-cli bower
bower install
grunt debug
````

This does two things:

* run a watch process which detects changes to source files and triggers refreshes of the extension
* run a server on which you can run tests (see "Running the tests" below)

Open Chrome and go to `Tools > Extensions`, check Developer Mode in the top right. Click `Load unpacked extension` and point it to the `app/` directory in the project. This should load up the extension and you should be able to see the page action icon in the URL bar.

Try changing popup.html it should automatically refresh the extension. After clicking the icon you should be able to see the changes you've made in the popup.


# Running the tests

The `grunt debug` task's been wired up to start a server for running the test scripts. Please go to `localhost:9010` to run the tests suite and see its output.

You can also run `grunt test` to run the test suite, but the server is not persistent, so it's more difficult to debug the tests if you need to.
