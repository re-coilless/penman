import os
import re
#https://github.com/logankilpatrick/TODO-List-Updater/tree/master

from pathlib import Path
repo_root = Path(__file__).resolve().parents[2]
file_path = repo_root / os.getenv( "VERSIONING_PATH" )

with open( file_path, "r", encoding = "utf-8" ) as file:
    content = file.read()

import subprocess
message = re.search( r"\(vol\s+([0-9.]+)\)", os.getenv( "COMMIT_MESSAGE", "" ))
message = message.group(1) if message else "unknown"
commit = os.getenv( "COMMIT_HASH", "" )

lines = content.splitlines()
body = "\n".join(lines[15:])
marker = os.getenv( "VERSIONING_MARKER" )
marker_ = re.escape(marker)
header = re.sub(
    rf'^{marker_}.*$',
    f'{marker}{message} -- {commit}',
    "\n".join(lines[:15]),
    flags=re.MULTILINE
)

with open( file_path, "w", encoding="utf-8" ) as file:
    file.write( header + "\n" + body )