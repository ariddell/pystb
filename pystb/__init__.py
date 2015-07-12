import pbr.version

from .stable import *  # noqa

__version__ = pbr.version.VersionInfo(
    'pystb').version_string()
