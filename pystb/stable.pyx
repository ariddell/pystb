#cython: language_level=3
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True


from libc.stdint cimport uint32_t
from libc.stdio cimport FILE, tmpfile, rewind, fclose, fread
from libc.string cimport memset


cdef extern from "stable.h":
    # private data structure, no access needed
    ctypedef struct stable_t:
        pass
    stable_t *S_make(unsigned int initN, unsigned int initM, unsigned int maxN, unsigned int maxM, double a, uint32_t flags)
    void S_free(stable_t *sp)
    void S_report(stable_t *sp, FILE *fp)
    double S_S(stable_t *sp, unsigned int n, unsigned int m)
    double S_S1(stable_t *sp, unsigned int n)
    int S_STABLE
    int S_UVTABLE
    int S_FLOAT
    int S_VERBOSE
    int S_QUITONBOUND
    int S_THREADS


cdef class STable:
    """Table of pre-calculated generalised Stirling numbers of the second kind.

    For fixed ``a``, pre-calculate all Stirling numbers of the second kind with
    the following form:

    .. math::
        S^n_{m,a}

    The maximum ``n`` and maximum ``m`` values must be specified in advance
    as well.

    Example:

    >>> import pystb
    >>> stable = pystb.STable(100, 100, 0.5)
    >>> stable.S(5, 3)  # S^5_{3, 0.5}
    >>> stable[5, 3]  # alias for stable.S(5, 3)

    Attributes:
        max_n (int): Maximum `n` to calculate
        max_m (int): Maximum `m` to calculate
    """
    cdef:
        stable_t * _thisptr
        public unsigned int max_n
        public unsigned int max_m
        public double a

    def __cinit__(self, unsigned int max_n, unsigned int max_m, double a):
        self.max_n, self.max_m, self.a = max_n, max_m, a
        self._thisptr = S_make(10, 10, max_n, max_m, a, S_STABLE|S_UVTABLE|S_FLOAT|S_QUITONBOUND)
        if not self._thisptr:
            raise MemoryError("Couldn't allocate memory for STable.")

    def S(self, unsigned int n, unsigned int m):
        """:math:`log S^n_{m, a}`"""
        if n > self.max_n or m > self.max_m:
            raise ValueError("Indices exceed table bounds.")
        return S_S1(self._thisptr, n) if m == 1 else S_S(self._thisptr, n, m)

    def S1(self, unsigned int n, unsigned int m):
        """:math:`log S^n_{1, a}` for n >= 1"""
        assert n >= 1
        if n > self.max_n:
            raise ValueError("Indices exceed table bounds.")
        return S_S1(self._thisptr, n)

    def __getitem__(self, indices):
        """Convenient access, to ``self.S``, ``stable[n, m]`` calls ``stable.S(n, m)``."""
        if not isinstance(indices, tuple) and len(indices) == 2:
            raise ValueError("Expected two integer table indices.")
        return self.S(*indices)

    def __dealloc__(self):
        S_free(self._thisptr)

    def __str__(self):
        cdef:
            FILE* fp
            char buf[1024]
            size_t num_read

        memset(buf, 0, sizeof(buf))
        fp = tmpfile()
        S_report(self._thisptr, fp)
        rewind(fp)
        num_read = fread(buf, 1, sizeof(buf), fp)  # avoids unused result warning
        fclose(fp)
        return buf.strip().decode('ascii')
