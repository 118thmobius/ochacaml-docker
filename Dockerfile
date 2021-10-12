FROM ubuntu
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    patch \
    rlwrap \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /root
RUN curl -LO http://caml.inria.fr/pub/distrib/caml-light-0.75/cl75unix.tar.gz && tar xpfvz cl75unix.tar.gz && rm -f cl75unix.tar.gz
RUN curl -LO http://pllab.is.ocha.ac.jp/~asai/OchaCaml/download/OchaCaml.tar.gz && tar xpfvz OchaCaml.tar.gz && rm -f OchaCaml.tar.gz
RUN patch -p0 < OchaCaml/OchaCaml.diff && rm -f OchaCaml/OchaCaml.diff
WORKDIR cl75/src
RUN sed -ie "s/-no-cpp-precomp//" Makefile && make configure && make world
WORKDIR /root
ENV PATH "${PATH}:/root/OchaCaml"
RUN echo 'alias ochacaml="rlwrap ochacaml"' >> ~/.bashrc
