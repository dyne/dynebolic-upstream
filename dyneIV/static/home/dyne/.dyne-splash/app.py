#!/usr/bin/python3
# Copyright Lorenzo L. Ancora - 2024.
# Licensed under the European Union Public License 1.2
# SPDX-License-Identifier: EUPL-1.2
# Created for the Dynebolic project.

from importlib import import_module
from os import getenv, abort
from sys import version_info, stderr


#region Interpreter version checking
if version_info < (3, 11):
   print("Dyne Splash requires Python 3.11 or superior.", file=stderr)
   abort()
#endregion Interpreter version checking

#region uWSGI init
dynesplash = import_module('dyne-splash')
app = dynesplash.app
app.debug = getenv("DEBUG") is not None
#endregion uWSGI init

if __name__ == "__main__":
    from threading import Thread
    from socket import getservbyname
    from os import getcwd
    from json import load
    from werkzeug.serving import BaseWSGIServer

    #region Application configuration
    browserpath = None
    browserargs = None
    ipv4host = None
    serv = None
    try:
        cfg = load(open("ds-config.json"))
        cfg = cfg["Dyne Splash"]
        browserCfg = cfg["Web Browser"]
        browserpath = browserCfg['path']
        browserargs = browserCfg['args']
        urlCfg = browserCfg["Target URL"]
        urlargs = urlCfg['query']
        localsocketCfg = cfg["Local Socket"]
        ipv4Cfg = localsocketCfg['IPv4']
        ipv4host = ipv4Cfg['host']
        servDBCfg = localsocketCfg['Services DB']
        serv = (servDBCfg['name'], servDBCfg['proto'])
        setattr(app, "tutorial", cfg["Tutorial"])
        app.jinja_env.globals["mainNavMenu"] = cfg["Main Navigation Menu"]
    except FileNotFoundError as fe:
        app.logger.fatal(f"{getcwd()}/config.json cannot be accessed: {fe}")
        abort()
    except KeyError as ke:
        app.logger.fatal(f"{getcwd()}/config.json is missing a required key: {ke}")
        abort()
    except Exception as e:
        app.logger.fatal(f"{getcwd()}/config.json cannot be loaded: {e}")
        abort()
    #endregion Application configuration

    #region System configuration
    listenport = 5055  # Fallback
    try:
        listenport = getservbyname("dyne-splash", "tcp")
    except OSError:
        print("dyne-splash internet service name not found.", file=stderr)
        print("Please append \"dyne-splash 5055/tcp\" to /etc/services", file=stderr)
    #endregion System configuration
    
    #region Threads
    def run_local_webserver():
        app.run(host=f"127.0.0.{ipv4host}", port=listenport, use_evalex=False, load_dotenv=True)
    dyneSplash: Thread = Thread(target=run_local_webserver, name="dyne-splash-webserver")
    dyneSplash.start()
    
    def start_falkon_web_browser():
        from subprocess import run
        from time import sleep

        sleep(3.0)
        run(executable=browserpath, args=browserargs + [f"http://{f'127.0.0.{ipv4host}'}:{listenport}/{urlargs}"])


    falkonBrowser: Thread = None
    def run_system_web_browser(*args, **kvargs):
        global falkonBrowser

        if falkonBrowser is not None:
            return
        falkonBrowser = Thread(target=start_falkon_web_browser, name="dyne-splash-web-browser", daemon=True)
        falkonBrowser.start()

    BaseWSGIServer.service_actions = run_system_web_browser
    #endregion Threads
else:
    app.logger.critical(f"please execute {__file__} directly in a command shell.")
    del app
    abort()

