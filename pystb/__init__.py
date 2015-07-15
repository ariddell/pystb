import pbr.version

from .stable import STable  # noqa

__version__ = pbr.version.VersionInfo(
    'pystb').version_string()
