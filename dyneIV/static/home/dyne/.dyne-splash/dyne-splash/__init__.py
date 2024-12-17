# Copyright Lorenzo L. Ancora - 2024.
# Licensed under the European Union Public License 1.2
# SPDX-License-Identifier: EUPL-1.2
# Created for the Dynebolic project.

from flask import Flask, render_template, request, abort
from flask.templating import TemplateNotFound
from docutils.core import publish_parts
from jinja2 import FileSystemBytecodeCache
from logging import getLogger, LogRecord
from pathlib import Path
from signal import signal, strsignal, SIGUSR1
from types import TracebackType

__version__ = "1.0.0-beta" # Dyne Splash version

API_PATH = "/dyne-splash/api/v1"

envtype = None
cfgDir = None
homeDir = Path.home()
liveDir = Path('/run/live/')
if liveDir.is_dir():
    cfgDir = liveDir
    envtype = 'live'
else:
    cfgDir = homeDir.joinpath(".config/dyne-splash/")
    envtype = 'installed'

assert envtype is not None 
assert cfgDir is not None 
noSplashFile = cfgDir.joinpath('nosplash')

app: Flask = Flask(__name__)

app.jinja_env.bytecode_cache = FileSystemBytecodeCache(pattern="__jinja2_%s.dyne_splash.cache")

def clear_cache(signum: int, frame: type(TracebackType.tb_frame)):
    app.jinja_env.bytecode_cache.clear()
    app.logger.warn(f"SIG {strsignal(signum)}: Jinja bytecode cache cleared.")


signal(SIGUSR1, clear_cache)


#region Framework logger filtering
def __ffunc(r: LogRecord) -> True:
    if "development server" in r.msg:
        nr: str = r.msg.split('* ')[1]
        r.msg = f" * {nr} (this is a local webserver and cannot be accessed from outside your computer)"
    return True


beLogger = getLogger(name='werkzeug')
beLogger.addFilter(__ffunc)
del beLogger
#endregion Framework logger filtering

#region Page routes
@app.route("/")
@app.route("/<pagename>")
def common_page(pagename:str = "start"):
    p: str = str()

    try:
        ppath: str = f"{app.tutorial['root']}/{envtype}/{pagename}.{app.tutorial['format']}"
        fpath: Path = ""
        fc: str = ""

        with open(file=ppath) as f:
            fpath = Path(f.name)
            fc = f.read()
        htmlparts: dict[str,str] = publish_parts(source=fc, parser_name='rst', writer_name='html5')
        p = render_template("page.html5.jinja2", envtype=envtype, current_page=htmlparts, current_page_name=fpath)
    except TemplateNotFound as tnfe:
        if request.accept_mimetypes.accept_html is True:
            return render_template("default.html5.jinja2", problem="Template not found", details=tnfe.args)
        else:
            return ({"Error":{"Template not found": tnfe.message}}, 404)
    except FileNotFoundError as fnfe:
        if request.accept_mimetypes.accept_html is True:
            return render_template("default.html5.jinja2", problem="Tutorial page not found", details=fnfe.args + (fnfe.filename,))
        else:
            return ({"Error":{"Tutorial page not found": fnfe.filename}}, 404)
    except Exception as e:
        if request.accept_mimetypes.accept_html is True:
            return render_template("default.html5.jinja2", problem=str(type(e)), details=e.args)
        else:
            return ({"Error":{str(e): e.args}}, 500)

    return p


@app.route("/about")
def about_page():
    return render_template("about.html5.jinja2")
#endregion Page routes

#region REST API routes
@app.route(f"{API_PATH}/splash", methods=['GET', 'POST'])
def api_splash():
    if request.method == 'GET':
        return {'splash': noSplashFile.exists(), 'path': noSplashFile.resolve().as_uri()}

    if 'splash' not in request.values:
        abort(400)
    mustsplash = request.values.get('splash', type=int)
    if mustsplash == 1:
        noSplashFile.unlink(missing_ok=False)
    elif mustsplash == 0:
        noSplashFile.touch(exist_ok=True)
    else:
        abort(400)

    return {'splash': noSplashFile.exists(), 'path': noSplashFile.resolve().as_uri()}


@app.route(f"{API_PATH}/directories", methods=['GET'])
def directories():
    return {'live': str(liveDir.absolute()), 'home': str(homeDir.absolute()), 'cwd': str(Path.cwd().absolute()), 'self': __file__}


@app.route(f"{API_PATH}/environment", methods=['GET'])
def environment():
    return {'type': envtype}


@app.route(f"{API_PATH}/version", methods=['GET'])
def api_version():
    return {'version': __version__}
#endregion REST API routes


if __name__ == "__main__":
    from os import abort
    
    app.logger.critical(f"{__file__} is a module, please run dyne-splash/app.py instead.")
    abort()