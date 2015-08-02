import pbr.version

from .stable import STable  # noqa
from .lgamma import gammadiff, psidiff  # noqa

__version__ = pbr.version.VersionInfo(
    'pystb').version_string()
