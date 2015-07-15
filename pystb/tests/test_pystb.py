import math

import pystb
from pystb.tests import base


class TestPystb(base.TestCase):

    def test_basic(self):
        stable = pystb.STable(100, 100, 0)
        self.assertAlmostEqual(stable.S(6, 3), math.log(225))
