#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import subprocess
import sys

def process_file(cmd):
    commits = {}
    p1 = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    for line in p1.stdout:
        stuff = line.decode().split(')') # want: hash (commit stuff) file_line, dropping file line
        if len(stuff) != 2:
            continue
        hash = stuff[0].split(' ')
        if hash[0] in commits:
            continue
        commits[hash[0]] = stuff[0] + ')'
    return commits

# take a list of git controlled filenames and print fname + commit-info
# note works well with powershell after doing this:
#    function lc { python.exe C:\_me\scripts\list-commits.py $args }
if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Need at least one filename to pull commits")
        sys.exit(-1)

    here = os. getcwd()
    for i in range(1, len(sys.argv)):
        try:
            folder = os.path.dirname(sys.argv[i])
            fname = os.path.basename(sys.argv[i])
            os.chdir(folder) # cd to folder
            cmd = ['git', 'blame', fname]
            commits = process_file(cmd)
            print(folder + ':')
            for k,v in sorted(commits.items()):
                print(fname, v)
            os.chdir(here)  # cd to here
        except BaseException as err:
            print("failed: " + sys.argv[i], type(err))
