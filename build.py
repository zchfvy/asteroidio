#!/usr/bin/env python

import argparse
import subprocess
import os
import shutil
import SimpleHTTPServer
import SocketServer
import threading
import time
import webbrowser

parser = argparse.ArgumentParser(description="Build the Game")
parser.add_argument('command',
                    choices=['build', 'clean', 'run'])
parser.add_argument('--config',
                    choices=['debug',
                             'release',
                             'release-compatibility',
                             'release-performance'],
                    default='debug',
                    help='Configuration to build')
parser.add_argument('--port', type=int, default=5000)

args = parser.parse_args()

if args.config == 'release':
    args.config = 'release-compatibility'

lovejs = os.environ.get('LOVEJS', os.path.abspath('../love.js/'))
out_dir = os.path.join('dist', args.config)
in_dir = './src'


if args.command == 'build':
    if not os.path.exists(out_dir):
        orig_path = os.path.join(lovejs, args.config)
        shutil.copytree(orig_path, out_dir)

    cline = ['python',
             os.path.join(lovejs, 'emscripten/tools/file_packager.py'),
             os.path.join(out_dir, 'game.data'),
             '--preload',
             os.path.join(in_dir, '@/'),
             '--js-output=' + os.path.join(out_dir, 'game.js')]

    print('>' + ' '.join(cline))

    subprocess.call(cline)


if args.command == 'clean':
    shutil.rmtree(out_dir)

if args.command == 'run':
    os.chdir(out_dir)

    Handler = SimpleHTTPServer.SimpleHTTPRequestHandler
    httpd = SocketServer.TCPServer(("", args.port), Handler)
    print("Serving on port {}".format(args.port))
    t = threading.Thread(target=httpd.serve_forever, args=())
    t.daemon = True
    t.start()

    webbrowser.open('http://localhost:{}'.format(args.port), new=2)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n")
        print("<Ctrl>+C detected, exiting.")
        print(" - This may take a few moments: Please Be Patient - ")
    httpd.shutdown()
    httpd.server_close()
