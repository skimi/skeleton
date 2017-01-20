# Tests

## End to end tests

End to end tests are run by [NightWatchJs](http://nightwatchjs.org/) on selenium servers.

### Commands

- **make e2e-local** : Runs the tests on a local chrome browser
- **make APP_URL=http://yoursite.com e2e-live -- --arguments** : Runs the tests on chrome, ie, safari & firefox on TestingBot with a specified website URL.

You can pass any argument accepted by nightwatch. See the [documentation](http://nightwatchjs.org/guide#command-line-options) for a complete list.

Example:
```bash
# runs the tests tag google on the google.com website
make APP_URL=http://www.google.com e2e-live -- --tag google
```

### Writing tests

Example:
```js
// Import the callback that updates the distant selenium server
var testingBotCallback = require('./testingBotCallback');

module.exports = {
    // Tag your test accordingly or place it in a specific subfolder (group)
    '@tags': ['onyx'],
    // You must call testingBotCallback after the test otherwise the test won't end and the selenium server won't receive any status update
    after: testingBotCallback,
    "Onyx starter template": function(browser) {
        browser
            // Use the browser.globals.appUrl variable as a base for your url instead of specifying it in code. This allows above commands to test different websites.
            .url(browser.globals.appUrl)
            .waitForElementVisible('body', 1000)
            .assert.containsText('body', 'Bootstrap starter template');
    }
};
```

See [Getting started with NightWatchJS](http://nightwatchjs.org/getingstarted) and [NightWatch API Reference](http://nightwatchjs.org/api).
