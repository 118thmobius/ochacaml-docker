FROM ubuntu:20.04
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    patch \
    rlwrap \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/*

ARG OCHACAML_GROUP=ochacaml
ARG OCHACAML_USER=ochacaml
ARG OCHACAML_DIR=/home/${OCHACAML_USER}/.ochacaml

RUN groupadd -r ${OCHACAML_GROUP} && useradd -m -g ${OCHACAML_GROUP} ${OCHACAML_USER}
USER ${OCHACAML_USER}

RUN mkdir ${OCHACAML_DIR}
WORKDIR ${OCHACAML_DIR}

RUN curl -LO http://caml.inria.fr/pub/distrib/caml-light-0.75/cl75unix.tar.gz && tar xpfvz cl75unix.tar.gz && rm -f cl75unix.tar.gz
RUN curl -LO http://pllab.is.ocha.ac.jp/~asai/OchaCaml/download/OchaCaml.tar.gz && tar xpfvz OchaCaml.tar.gz && rm -f OchaCaml.tar.gz

RUN patch -p0 < OchaCaml/OchaCaml.diff && rm -f OchaCaml/OchaCaml.diff
RUN sed -i -e "s@~/cl75/src@${OCHACAML_DIR}/cl75/src@" OchaCaml/ochacaml

WORKDIR cl75/src
RUN sed -i -e "s/-no-cpp-precomp//" Makefile && make configure && make world

ENV PATH "${PATH}:${OCHACAML_DIR}/OchaCaml"
WORKDIR /home/${OCHACAML_USER}
RUN echo 'alias ochacaml="rlwrap ochacaml"' >> ~/.bashrc
