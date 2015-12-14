This repository contains notes and experiments on creation of a Book about
[Catmandu](https://librecat.org/Catmandu).

# Overview

The book should be generated automatically from several sources:

* [Catmandu Wiki](https://github.com/LibreCat/Catmandu/wiki) (see 
  <http://librecat.org/Catmandu/> for generated summary from wiki content)

* Module documentation (POD)

* Maybe some additional texts

* Layout files and scripts

# Current state

The repository only contains some helper scripts (see `Makefile`) to:

* clone/pull from the Catmandu wiki (`make wiki`)

* download all Catmandu distributions from CPAN (`make download`)

* extract a list of all modules from distributions (`make modules`)

