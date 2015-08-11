#cython: language_level=3
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cdef extern from "lgamma.h":
    double libstb_gammadiff "gammadiff"(int N, double alpha, double lga)
    double libstb_psidiff "psidiff"(int N, double alpha, double pa)

def gammadiff(int N, double alpha, double lga):
    """Faster version of lgamma(N+alpha)-lgamma(alpha).

    `lga` is precomputed version of lgamma(alpha)
    """
    return libstb_gammadiff(N, alpha, lga)

def psidiff(int N, double alpha, double pa):
    return libstb_psidiff(N, alpha, pa)
