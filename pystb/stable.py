

# TODO(AR): rewrite in Cython
class STable:

    def __init__(self, init_N, init_M, max_M, max_N, a):
        if a != 0:
            raise NotImplementedError

    def S(self, n, m):
        """log S^n_{m,a}"""
        # TODO(AR): implement
        return -1

    def __getitem__(self, indices):
        if not (isinstance(indices, tuple) and len(indices) == 2):
            raise TypeError("STable indices must be a 2-tuple, not an integer")
        return self.S(*indices)

    def __del__(self):
        pass
