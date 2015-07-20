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
    stable_t *S_make(unsigned initN, unsigned initM, unsigned maxN, unsigned maxM, double a, uint32_t flags)
    void S_free(stable_t *sp)
    void S_report(stable_t *sp, FILE *fp)
    double S_S(stable_t *sp, unsigned n, unsigned m)
    double S_S1(stable_t *sp, unsigned n)
    int S_STABLE
    int S_UVTABLE
    int S_FLOAT
    int S_VERBOSE
    int S_QUITONBOUND
    int S_THREADS


cdef class STable:
    cdef stable_t * thisptr
    cdef public max_n
    cdef public max_m

    def __cinit__(self, unsigned max_n, unsigned max_m, double a):
        self.thisptr = S_make(max_n, max_m, max_n, max_m, a, S_STABLE|S_UVTABLE|S_FLOAT|S_QUITONBOUND)
        self.max_n = max_n
        self.max_m = max_m
        if not self.thisptr:
            raise MemoryError("Couldn't allocate memory for STable.")

    def S(self, unsigned n, unsigned m):
        """log S^n_{m, a}"""
        if n > self.max_n or m > self.max_m:
            raise ValueError("Indices exceed table bounds.")
        if m == 1:
            return S_S1(self.thisptr, n)
        return S_S(self.thisptr, n, m)

    def S1(self, unsigned n, unsigned m):
        """log S^n_{1, a}"""
        if n > self.max_n:
            raise ValueError("Indices exceed table bounds.")
        return S_S1(self.thisptr, n)

    def __getitem__(self, indices):
        """Convenient access, to self.S, stable[n, m] calls stable.S(n, m)"""
        if not isinstance(indices, tuple) and len(indices) == 2:
            raise ValueError("Expected two integer table indices.")
        return self.S(*indices)

    def __dealloc__(self):
        S_free(self.thisptr)

    def __str__(self):
        cdef FILE* fp
        cdef char buf[1024]
        cdef size_t num_read
        memset(buf, 0, sizeof(buf))
        fp = tmpfile()
        S_report(self.thisptr, fp)
        rewind(fp)
        num_read = fread(buf, 1, sizeof(buf), fp)  # avoids unused result warning
        fclose(fp)
        return buf.strip().decode('ascii')
