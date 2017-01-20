var TestingBot = require('testingbot-api');

module.exports = function testingBotCallback (browser, forceEnd = true) {
    if (typeof browser.globals.tbKey !== 'undefined'
        && typeof browser.globals.tbSecret !== 'undefined'
        && browser.globals.tbKey !== null
        && browser.globals.tbSecret !== null) {
        var tb = new TestingBot({
            api_key: browser.globals.tbKey,
            api_secret: browser.globals.tbSecret
        });

        tb.updateTest({
            'test[name]': browser.options.desiredCapabilities.name,
            'test[success]': browser.currentTest.results.passed === browser.currentTest.results.tests
        }, browser.sessionId, (error, success) => {
            if (typeof error !== 'undefined' && error !== null) {
                console.error(error);
            } else {
                console.log('Testing bot updated');
            }
        });
    }

    if (forceEnd) {
        browser.end();
    }
}
