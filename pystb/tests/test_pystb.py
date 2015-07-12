"""
test_pystb
----------------------------------

Tests for `pystb` module.
"""

from pystb.tests import base

import pystb


class TestPystb(base.TestCase):

    def test_something(self):
        stable = pystb.STable(1, 1, 10, 10, 0)
        self.assertIsInstance(stable[5, 1], int)
