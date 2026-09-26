#import "/lib.typ": *

#let engagement(who, when, body) = html.li({
  html.span(class: "who", who)
  html.span(class: "when", when)
  html.div(class: "what", body)
})

#let personal-about = [
  I'm Gonzalo Barrera Borla, a statistician and machine-learning engineer in Buenos Aires. My models have priced programmatic ad auctions (#link("https://www.jampp.com/")[Jampp]) and NASCAR fan-club subscriptions, sized correlated parlays (joint Kelly) for a horse-race betting syndicate, flagged crypto-wallet fraud (#link("https://muun.com/")[Muun]), and matched people looking for love (#link("https://download.joinsitch.com/")[Sitch]). I really like problems where statistics meets the P&L: risk, matching, pricing, optimization.

  This blog is where I write things down at the length they need, mostly in Spanish. Corrections and questions are welcome by email.

  == Experience

  #html.ul(class: "engagements", {
    engagement("Sitch", "2025–", [First data hire at a matchmaking startup that replaces swiping with curated candidate lists. Replaced LLM-only affinity scoring with chat-NLP extraction, gradient-boosted match probabilities and greedy b-matching: from over 10K USD a month in OpenAI fees to a few bare-metal VMs, holding match quality while growing from 3K to 30K MAU.])
    engagement("Muun Wallet", "2024–25", [Data scientist on the anti-fraud team of a self-custodial Bitcoin and Lightning wallet. Real-time incongruity detection plus on-chain and Lightning contracts took micro-fraud of about 2 BTC a month (over 200K USD a month then) to near zero.])
    engagement("Move 37", "2023–24", [Head of data science (team of 4) for a pari-mutuel horse-racing syndicate across LATAM and the US: joint Kelly sizing over correlated wagers, estimated joint distributions for exotic bets. Volume more than doubled at stable margins.])
    engagement("Jampp", "2021–22", [Engineering manager, data science. Led the move from a bespoke online-SGD logistic regression to batch LightGBM, unlocking per-client, per-geo models; wrote the team's career ladder and grew it to 12 people.])
    engagement("Jampp", "2019–20", [Senior data scientist on the conversion-rate models (win rate, CTR, CVR) behind a real-time bidder scoring 1M+ auctions per second. Co-developed the income-optimization engine that replaced 100+ per-client bidding problems with one global objective; annualized revenue grew about 4×, from about USD 15M to 60M+.])
    engagement("Jefatura de Gabinete de Ministros", "2016–19", [Built the data model and ETLs of a BI system integrating Argentina's national public administration: payroll for about 400K civil and military employees and the roughly USD 156B national budget with its monthly execution.])
  })

  == Work & talks

  - _Fermat distances in kernel density classifiers_ (MA thesis): density-based geodesic distances on Riemannian manifolds for nonparametric classification, with a `scikit-learn`-compatible library. #link("posts/fermat-01-la-tesis-en-un-post.html")[Blog series], #link("https://github.com/capitantoto/fermat")[code], #link("https://github.com/capitantoto/fermat/blob/main/docs/tesis.pdf")[thesis]. Instituto de Cálculo, FCEN-UBA (2026).
  - _Optimal bidding: a dual approach_: the income-optimization engine behind globally optimal RTB bidding at Jampp. #link("http://papers.adkdd.org/2019/papers/adkdd19-pita-optimal.pdf")[AdKDD] and #link("https://www.youtube.com/watch?v=tGC1mRJ7DQU")[PyData AR] (2019).
  - _Machine Learning in Graphs_: a semester course on learning and optimization on graph-structured data, fully open. #link("https://github.com/fcen-amateur/aa-en-grafos")[Materials] and #link("https://www.youtube.com/playlist?list=PL1WsZAYeCpYUA-k5Ry5O803GpipEnoFQk")[video lectures]. With Martín Elías Costa, FCEN-UBA (2021).
  - _Si nos organizamos, nos enamoramos todos_: embedding learned random estimates in linear optimization, applied to finding love without swiping. #link("https://github.com/capitantoto/matchmaking-udesa")[Notebook and slides]. Sitch and Universidad de San Andrés, MCD (2026).
  - _The limits of electoral predictability_ (BA thesis): Monte Carlo simulations of election-night partial tallies for Buenos Aires legislative elections, from open data. #link("https://github.com/capitantoto/tesis_mesis")[Code], #link("https://github.com/capitantoto/tesis_mesis/blob/master/texes/tesis.pdf")[thesis]. FCE-UBA (2014).
  - #link("https://github.com/datosgobar/pydatajson")[pydatajson]: CKAN open-data metadata library for Argentina's national data portal, featured in the IADB's "Code for Development" program.

  == Teaching

  #html.ul(class: "engagements", {
    engagement("Instituto de Cálculo, UBA", "2023–25", [Teaching Assistant: "Intro to Statistics and Data Science" and "Data Laboratory"; materials at #link("https://github.com/fcen-amateur")[fcen-amateur].])
    engagement("FCEyN, UBA", "2021", [External professor, "Machine Learning in Graphs".])
    engagement("Mathematical olympiad coach", "2012–17", [])
  })

  == Education

  #html.ul(class: "engagements", {
    engagement("MA in Mathematical Statistics, UBA — coursework completed, thesis defense pending", "2017–", [Instituto de Cálculo; GPA 10.0.])
    engagement("BA in Economics, UBA", "2009–14", [Facultad de Ciencias Económicas; _magna cum laude_, class valedictorian.])
  })

  == Elsewhere

  #link(person.github)[GitHub] · #link(person.linkedin)[LinkedIn] · #link("mailto:" + person.email, person.email)

  #html.p(class: "tototren", [Todos a bordo del tototren! — this site, 2014–2026])
]

#let consulting-about = [
  Borlandux LLC is my one-person machine-learning and statistics consultancy, a Wyoming LLC founded in 2023. The work is the same as on the rest of this site: turning a messy question into a model whose numbers can be trusted, then getting it into production.

  == How I work

  *Embedded.* I join your team part- or full-time for a period, work in your repositories and meetings, and hand over as I go.

  *Scoped.* A fixed deliverable over a few weeks. When the problem or the system is unclear, we start with a short paid discovery: I look at the data and the decision it has to support, and come back with a written plan, a price and what success looks like. You can take the plan elsewhere.

  == Selected engagements

  #html.ul(class: "engagements", {
    engagement("Sitch", "2025–", [Matchmaking: replaced LLM-only affinity scoring with chat extraction, gradient-boosted match probabilities and b-matching; LLM spend cut by over 95% while users grew from 3K to 30K MAU.])
    engagement("Muun Wallet", "2024–25", [Real-time fraud detection for a self-custodial Bitcoin and Lightning wallet; micro-fraud of about 2 BTC a month taken to near zero.])
    engagement("Move 37", "2023–24", [Led quantitative R&D for a pari-mutuel horse-racing syndicate: joint Kelly sizing over correlated wagers, pricing of exotic bets; volume doubled at stable margins.])
    engagement("Cold-storage warehousing, US", "2023", [Order fulfillment-time predictions served inside the client's ERP.])
  })

  == Contact

  #link("mailto:" + company.email, company.email) --- a few lines on the problem are enough to start.
]

#show: page.with(
  title: if consulting { "Consulting" } else { "About" },
  current: "about",
  description: if consulting { "Borlandux LLC: machine-learning and statistics consulting by Gonzalo Barrera Borla." } else { "About Gonzalo Barrera Borla." },
)

#image("/assets/img/gonzalo.png", alt: "Gonzalo Barrera Borla")
#if consulting { consulting-about } else { personal-about }
