---
layout: default
title: "What is a Fermat distance, and why should your classifier care?"
date: 2026-07-30
---

# What is a Fermat distance, and why should your classifier care?

*First of two posts distilling my MSc thesis
([code & full text](https://github.com/capitantoto/fermat)). This one: the
idea. The next one: the experiments, honestly reported.*

I spent the last few years writing a Master's thesis in statistics about a
deceptively simple question: **what do you mean, "distance"?**

Every classifier you've ever used has an opinion about distance, even when it
doesn't say so out loud. k-nearest-neighbours is explicit about it. Kernel
density estimation smuggles it in through the kernel. And in almost every
library, the default opinion is the same: the distance between two points is
the length of the straight line between them. Euclid said so, case closed.

Here's the problem: in high dimensions, straight lines are a lie.

## Your data doesn't live where you think it lives

Take a megapixel photo of a handwritten digit. Formally, it's a point in a
million-dimensional space. But almost none of that space contains anything
that looks like a digit — random points there look like TV static. The images
that actually occur occupy a thin, curved, low-dimensional sliver of the
ambient space. This is the *manifold hypothesis*, and it's the single most
useful piece of geometric folklore in machine learning: high-dimensional data
tends to live on (or near) a low-dimensional surface.

<!-- figure candidate: docs/img/digitos-scatter.svg from the fermat repo -->

Once you buy the manifold hypothesis, Euclidean distance starts to embarrass
itself. Buenos Aires and Beijing are about 12,000 km apart if you're a plane,
but only ~10,500 km apart if you're a neutrino willing to tunnel through the
planet. For everything that lives *on the surface* — planes, people, data —
the honest distance is the geodesic: the shortest path *along the manifold*,
not through it.

Statisticians noticed this long ago. There are lovely classical results on
kernel density estimation on Riemannian manifolds (Pelletier 2005, Loubes &
Pelletier 2008) with one catch that kills them in practice: **they assume you
know the manifold.** You never know the manifold. If I knew the manifold, I
wouldn't be estimating densities on it; I'd be on a beach.

## Enter Fermat

The *Fermat distance* (Groisman, Jonckheere & Sapienza, 2022 — my thesis
director Pablo Groisman is one of the culprits) is a way to estimate geodesic
distances **from the sample itself**, without ever knowing the manifold or
even its dimension.

The idea is beautiful. Build a graph over your sample points. To travel
between two points, you must hop from data point to data point, and the cost
of a hop of Euclidean length ℓ is ℓ^α, with α > 1. The distance between two
points is then the cost of the *cheapest path* between them.

That exponent does all the work. With α > 1, one long hop costs more than
many short ones covering the same ground, so cheap paths are the ones that
travel through *dense* regions, where short hops are available. Distances
learn to follow the data. The name is no accident: this is Fermat's principle
from optics — light crossing media of varying refractive index doesn't take
the straight path, it takes the *fastest* one. Here, dense data is fast
medium.

<!-- figure candidate: espirales_lo-fkdc vs espirales_lo-svc decision
     boundaries from the fermat repo — Euclidean cuts across the spiral
     arms, Fermat follows them -->

Two points on neighbouring arms of a spiral are close in Euclidean distance
and *very* far apart in Fermat distance — you'd have to walk the whole spiral
to get from one to the other. Which is exactly what your classifier should
believe.

## So I built the thing

My thesis question: if the distance is the weakest link in density-based
classifiers, does swapping Euclidean → Fermat make them better? I took the
two most distance-hungry nonparametric classifiers — the kernel density
classifier (KDC) and k-nearest-neighbours — and built their Fermat versions,
f-KDC and f-kNN, as an open-source, scikit-learn-compatible library:
**[github.com/capitantoto/fermat](https://github.com/capitantoto/fermat)**.
`pip install`, `.fit()`, `.predict()`, the usual liturgy.

Then I evaluated everything the way I wish more papers did: systematically,
on 20 datasets, against strong baselines (SVMs, gradient boosting, logistic
regression), with honest variance estimates and a parsimony rule for
hyperparameters.

## Does it work? (the honest version)

Sometimes, and it's instructive *when*. f-KDC had the best median performance
on 7 of 20 datasets, f-kNN on 3 more. The gains concentrate exactly where the
theory says they should: **high curvature and sparse sampling** — the regime
where your data twists faster than your sample can keep up, which is
precisely where the classical manifold-KDE assumptions break down.

And when data is plentiful and the manifold is tame? The extra Fermat
parameter α turns out to be *functionally interchangeable* with the kernel
bandwidth — two knobs controlling the same thing — and Fermat matches
Euclidean without beating it. Fermat distance is a useful alternative to the
Euclidean default, not a universal upgrade. I consider "knowing when it
won't help" the most valuable result in the thesis.

In the next post: the actual experiments, including the part where I name
datasets after Argentine pastries (`pionono`), egg cartons (`hueveras`) and
chain links (`eslabones`), and what two thousand fitted classifiers taught me
about the curse of dimensionality.

---

*Thesis: "Distancia de Fermat en Clasificadores de Densidad por Núcleos",
MSc in Mathematical Statistics, FCEN-UBA, 2026, directed by Pablo Groisman.
[Full text (Spanish) & code](https://github.com/capitantoto/fermat).*

[Back home](/)
