ARG CURL=7.67.0
ARG TFENV=1.0.2
ARG TFLINT=0.13.2
ARG JQ=1.6
ARG TERRAFORM=0.11.14

FROM ubuntu:19.10 AS build

ARG CURL
ARG TFENV
ARG TFLINT
ARG JQ
ARG TERRAFORM

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq &&\
    apt-get upgrade -yqq &&\
    apt-get install -yqq \
        bash-static \
        curl \
        libdigest-sha-perl \
        unzip &&\
    cd /usr/local/share &&\
    # https://github.com/stedolan/jq/releases
    curl -sL https://github.com/stedolan/jq/releases/download/jq-$JQ/jq-linux64 > /usr/local/bin/jq &&\
    # https://github.com/terraform-linters/tflint/releases
    curl -sL https://github.com/terraform-linters/tflint/releases/download/v$TFLINT/tflint_linux_amd64.zip | funzip > /usr/local/bin/tflint &&\
    # https://github.com/tfutils/tfenv/releases
    curl -sL https://github.com/tfutils/tfenv/archive/v$TFENV.tar.gz | tar -xz &&\
    ln -s /usr/local/share/tfenv-$TFENV/bin/* /usr/local/bin/ &&\
    chmod +x /usr/local/bin/tflint &&\
    chmod +x /usr/local/bin/jq

# RUN tfenv install $(tfenv list-remote | head -1) &&\
#     tfenv install $TERRAFORM

FROM shakefu/curl-static AS curl

FROM busybox:glibc AS final

ARG TFENV

COPY --from=build /bin/bash-static /bin/bash
COPY --from=build /etc/ssl /etc/ssl
COPY --from=build /usr/local/share/tfenv-$TFENV /usr/local/share/tfenv-$TFENV
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=curl /usr/local/bin/curl /usr/local/bin/curl

RUN mkdir /usr/bin &&\
    mv /bin/sh /bin/ash &&\
    ln -sf /bin/bash /bin/sh &&\
    ln -s /bin/bash /usr/bin/bash &&\
    ln -s /bin/env /usr/bin/env &&\
    ln -sf /usr/local/share/tfenv-$TFENV/bin/* /usr/local/bin/

WORKDIR /src

ENTRYPOINT ["/bin/bash"]
