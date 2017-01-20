const TB_KEY = process.env.TB_KEY || 'e770f9f5e77adceb3d3a176e050a2b5a';
const TB_SECRET = process.env.TB_SECRET || 'dc46fe58b9e9b1940f95a79e0418515e'
const TB_HOST = 'hub.testingbot.com';
let APP_URL = 'http://localhost:' + (process.env.WEB_PORT || 80);

if (typeof process.env.APP_URL !== 'undefined' && process.env.APP_URL.length) {
    APP_URL = process.env.APP_URL;
}

console.log('Testing on ' + APP_URL);

nightwatch_config = {
    src_folders: ["tests/"],

    selenium: {
        "start_process": false,
        "host": TB_HOST,
        "port": 80
    },

    test_settings: {
        default: {
            end_session_on_fail: false,
            selenium_host: TB_HOST,
            selenium_port: 80,
            globals: {
                tbKey: TB_KEY,
                tbSecret: TB_SECRET,
                appUrl: APP_URL
            },
            desiredCapabilities: {
                'build': 'nightwatch-testingbot',
                'client_key': TB_KEY,
                'client_secret': TB_SECRET
            }
        },
        chrome: {
            desiredCapabilities: {
                browserName: "chrome",
                platform: "WIN8",
                version: "latest",
            }
        },
        firefox: {
            desiredCapabilities: {
                browserName: "firefox",
                platform: "WIN8",
                version: "latest",
            }
        },
        safari: {
            desiredCapabilities: {
                browserName: "safari",
                platform: "CAPITAN",
                version: "latest",
            }
        },
        ie: {
            desiredCapabilities: {
                browserName: "internet explorer",
                platform: "WIN8",
                version: "latest",
            }
        },
        'local': {
            selenium_host: 'localhost',
            selenium_port: 4444,
            globals: {
                tbKey: null,
                tbSecret: null
            },
            desiredCapabilities: {
                browserName: 'chrome'
            }
        }
    }
};

module.exports = nightwatch_config;
