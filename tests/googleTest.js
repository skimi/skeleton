var testingBotCallback = require('./testingBotCallback');

module.exports = {
    '@tags': ['google'],
    after: testingBotCallback,
    "Demo test Google": function(browser) {
        browser
            .url('http://www.google.com/ncr')
            .waitForElementVisible('body', 1000)
            .setValue('input[type=text]', 'nightwatch')
            .waitForElementVisible('button[name=btnG]', 1000)
            .click('button[name=btnG]')
            .pause(2000)
            .assert.containsText('#main', 'The Night Watch');
    },
    "Google search Naoned": function(browser) {
        browser
            .url('http://www.google.com/ncr')
            .waitForElementVisible('body', 1000)
            .setValue('input[type=text]', 'naoned')
            .waitForElementVisible('button[name=btnG]', 1000)
            .click('button[name=btnG]')
            .pause(2000)
            .assert.containsText('#main', 'Naoned');
    }
};
