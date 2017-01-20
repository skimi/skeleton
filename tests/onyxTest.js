var testingBotCallback = require('./testingBotCallback');

module.exports = {
    '@tags': ['onyx'],
    after: testingBotCallback,
    "Onyx starter template": function(browser) {
        browser
            .url(browser.globals.appUrl)
            .waitForElementVisible('body', 1000)
            .assert.containsText('body', 'Bootstrap starter template');
    }
};
