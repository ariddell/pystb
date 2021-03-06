=====
Usage
=====

An instance of the class ``STable`` provides access to (pre-calculated)
generalized Stirling numbers of the second kind, :math:`S^n_{m,a}`. Initialize
the table with the maximum ``n`` and maximum ``m`` which will be needed.

    >>> import pystb
    >>> stable = pystb.STable(10000, 10000, 0.5)
    >>> stable.S(5, 3)  # S^5_{3, 0.5}
    >>> stable[5, 3]  # alias for stable.S(5, 3)
