#!/usr/bin/python3
from bottle import request, route, template, run, static_file

# static files js/css/etc
@route('/static/<filepath:path>')
def static_files(filepath):
    return static_file(filepath,root='./static/')

@route('/')
def index():
    return template("bootstrap")

@route('/page')
def page():
    return "Index_Two"

run(reloader=True)
