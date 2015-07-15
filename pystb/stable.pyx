#cython: language_level=3
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

from libc.stdint cimport uint32_t

cdef extern from "stable.h":
    # private data structure, no access needed
    ctypedef struct stable_t:
        pass
    stable_t *S_make(unsigned initN, unsigned initM, unsigned maxN, unsigned maxM, double a, uint32_t flags)
    void S_free(stable_t *sp)
    double S_S(stable_t *sp, unsigned n, unsigned m)
    int S_STABLE
    int S_UVTABLE
    int S_FLOAT
    int S_VERBOSE
    int S_QUITONBOUND
    int S_THREADS



cdef class STable:
    cdef stable_t * thisptr

    def __cinit__(self, unsigned max_n, unsigned max_m, double a):
        self.thisptr = S_make(max_n, max_m, max_n, max_m, a, S_STABLE | S_UVTABLE)
        if not self.thisptr:
            raise MemoryError("Couldn't allocate memory for STable")

    def S(self, unsigned n, unsigned m):
        return S_S(self.thisptr, n, m)

    def __dealloc__(self):
        S_free(self.thisptr)
