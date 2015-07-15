import math

import pystb
from pystb.tests import base


class TestPystb(base.TestCase):

    def test_basic(self):
        stable = pystb.STable(1, 1, 10, 10, 0)
        self.assertIsInstance(stable[6, 3], int)
        self.assertEqual(stable[6, 3], 90)

    def test_basic_cython(self):
        stable = pystb.STable()
        result = stable.S(6, 3)
        self.assertEqual(result, math.log(90))
