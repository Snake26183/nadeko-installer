ARG DISTRO
FROM ${DISTRO}
WORKDIR /root

ARG UPD_CMD
ARG INST_CMD
RUN ${UPD_CMD} && ${INST_CMD}

ARG TOKEN
ENV bot_token=${TOKEN}
ENV AUTOMATED=true

ADD --chmod=755 https://raw.githubusercontent.com/Snake26183/nadeko-installer/refs/heads/main/Nadeko.sh ./
#ADD --chmod=755 https://raw.githubusercontent.com/Snake26183/nadeko-installer/refs/heads/main/distro-testing/wrapper.sh ./
COPY --chmod=755 wrapper.sh ./

ENTRYPOINT ["./wrapper.sh"]