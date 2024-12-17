# Details

See [../README.md](../README.md)

This is a local Python 3 + Flask application.<br>
Versioning: [SemVer 2.0.0](https://semver.org/).

# Execution

* Install Python 3 and Flask (use `pip` if possible);
* Allow the execution of this package: `chmod +x app.py`;
* Run the application: `./app.py`;
* The configured web browser will start automatically.

# Configuration

Dyne Splash can be configured via `ds-config.json`.<br>
The Flask local webserver can be configured via `.flaskenv`.

# REST API

API EP:

    /dyne-splash/api/v1

GET /version

    Return the current version of Dyne Splash.

GET /environment
    
    Return the current system environment.

GET /directories
    
    Return all important paths and file names.
    Also includes the current working directory.

GET /splash
    
    Return the autostart configuration file location and its status.

POST /splash
    
    Enable/disable the autostart.
    Parameter: splash=1/0

# Signals

SIGUSR1 can be used to clear the server cache without restarting Dyne Splash.<br>
If Dyne Splash is executed in background, SIGTERM can be used to terminate it gracefully.<br>
When in a terminal emulator, press CTRL + C or close the window to achieve the same.