import textwrap

import numpy as np
from scipy.special import gammaln as lgamma

import pystb


def falling_factorial(x, n):
    return lgamma(x + 1) - lgamma(x - n + 1)


def rising_factorial(x, n):
    return lgamma(x + n) - lgamma(x)


def log_prob_t_propto(t_k, n_k, alpha, theta_k, stable):
    assert alpha > 0
    assert 0 <= t_k <= n_k
    if n_k == 0:
        assert t_k == n_k
    return stable[n_k, t_k] + t_k * np.log(alpha * theta_k)


def sample_t(n, alpha, theta, stable):
    t = np.empty_like(n, dtype=int)
    for j in range(len(n)):
        if n[j] == 0:
            t[j] = 0
            continue
        log_prob = np.array([log_prob_t_propto(s, n[j], alpha, theta[j], stable) for s in range(1, n[j] + 1)])
        prob = np.exp(log_prob - max(log_prob))
        prob /= prob.sum()
        # zero probability of 0 if n_k > 0, so add 1
        t[j] = 1 + np.random.multinomial(1, prob).argmax()
    return t


def sample_theta(t, eta):
    """Sample theta from full condition.

    Default prior on theta is Dirichlet(eta * 1/K)
    """
    return np.random.dirichlet(t + eta * (1.0 / len(t)))


def run():
    p_true = np.array([0.1, 0.1, 0.6, 0.05, 0.05, 0.05, 0.05, 0, 0])
    x = (100 * np.ones(len(p_true)) * p_true).astype(int)
    K = len(x)

    print("true p:\n", p_true)
    print(textwrap.dedent(r"""
        Dirichlet-Multinomial with alpha,theta Dirichlet parameterization.
        alpha = 1.0, theta = 1/K
        Posterior for p:
    """))
    alpha = 1.0
    dirichlet_post = x + alpha * (1.0 / K)
    dirichlet_post = dirichlet_post / dirichlet_post.sum()
    print(dirichlet_post.round(3))

    print(textwrap.dedent(r"""
        PYP-Multinomial, alpha = 1.0, theta has Dirichlet hyperprior
        Dirichlet hyperprior has params \alpha^\prime = 1.0, \theta^\prime = 1/K
        Posterior mean for p:
    """))
    # integrate over samples of theta, posterior of PYP(0, 1, theta) is theta
    num_samples = 10000
    samples = np.empty((num_samples, K))

    t = np.zeros_like(x, dtype=int)

    # initial theta
    theta = x / np.sum(x)
    stable = pystb.STable(1e5, 1e5, 0)
    alpha = 1.0

    for i in range(num_samples):
        t = sample_t(x, alpha, theta, stable)
        theta = sample_theta(t, eta=1.0)
        samples[i] = theta
    print(np.mean(samples, axis=0).round(3))


if __name__ == '__main__':
    run()
