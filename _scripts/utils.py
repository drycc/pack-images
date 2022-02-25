import os
import sys
import platform as _platform

def toml():
    result = None
    with open(sys.argv[2]) as f:
        tpl = f.read()
        result = tpl.format(**os.environ)
    with open(sys.argv[3], "w") as f:
        f.write(result)

def platform():
    print(sys.platform)

def arch():
    print({
        "armv5": "armv5",
        "armv6": "armv6",
        "aarch64": "arm64",
        "x86": "386",
        "x86_64": "amd64",
        "i686": "386",
        "i386": "386",
    }.get(_platform.machine()))

if __name__ == "__main__":
    eval("%s()" % sys.argv[1])