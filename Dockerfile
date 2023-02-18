############################################
# Dockerfile that builds a MONGA SERVER    #
#            PROJECT ZOMBOID               #                   
############################################
FROM cm2network/steamcmd:root

LABEL maintainer="brunopoleza@outlook.com.br"

ENV STEAMAPPID 380870
ENV STEAMAPP pz
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-Dedicated"

# Instale os pacotes necessários

RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
      dos2unix \
      wget \
      ufw \
      unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Baixe o aplicativo de servidor dedicado do Project Zomboid usando o aplicativo steamcmd
# Defina as permissões do arquivo de ponto de entrada
RUN set -x \
  && mkdir -p "${STEAMAPPDIR}" \
  && chown -R "${USER}:${USER}" "${STEAMAPPDIR}" \
  && bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
                                    +login anonymous \
                                    +app_update "${STEAMAPPID}" validate \
                                    +quit

# Baixar save do Repositorio Git
# https://github.com/MongaGit/MONGA_PZServer

RUN mkdir -p /home/Zomboid/Saves/Multiplayer/ && cd /home/Zomboid/Saves/Multiplayer/  \
&& wget https://github.com/MongaGit/MONGA_PZServer/archive/refs/heads/main.zip \
&& unzip -o /home/Zomboid/Saves/Multiplayer/main.zip \
&& rm -r /home/Zomboid/Saves/Multiplayer/MONGA_PZServer \
&& mv /home/Zomboid/Saves/Multiplayer/MONGA_PZServer-main /home/Zomboid/Saves/Multiplayer/MONGA_PZServer 

# Abrindo portas necessarias
RUN ufw allow 16261:16264/udp
RUN ufw allow 27015/tcp

# Copie o arquivo do ponto de entrada
COPY --chown=${USER}:${USER} scripts/entry.sh /server/scripts/entry.sh
RUN chmod 550 /server/scripts/entry.sh

# Crie pastas necessárias para manter suas permissões na montagem
RUN mkdir -p "${HOMEDIR}/Zomboid"

WORKDIR ${HOMEDIR}
# Expose ports
EXPOSE 16261-16262/udp \
       27015/tcp

ENTRYPOINT ["/server/scripts/entry.sh"]


############################
## Bruno | MongaTech Inc. ##
############################
