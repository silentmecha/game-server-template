FROM silentmecha/{{IMAGE_BASE}}:latest

LABEL maintainer="silent@silentmecha.co.za"

ENV STEAMAPP_ID={{GAME_APP_ID}}
ENV STEAMAPP={{GAME_NAME_PASCAL_CASE}}
ENV STEAMAPPDIR="${HOME}/${STEAMAPP}-dedicated"
ENV STEAM_SAVEDIR=<<SET_SERVER_SAVE_DIR>>
ENV AUTO_UPDATE=True
ENV STEAM_LOGIN=anonymous

USER root

COPY ./src/entry.sh ${HOME}/entry.sh

RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		<<SETUP_PACKAGES>> \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

RUN set -x \
	&& mkdir -p "${STEAMAPPDIR}" \
	&& mkdir -p "${STEAM_SAVEDIR}" \
	&& chmod +x "${HOME}/entry.sh" \
	&& <<INSTALL_RCON_TOOL>> \
	&& chown -R "${USER}:${USER}" "${HOME}/entry.sh" "${STEAMAPPDIR}" "${STEAM_SAVEDIR}" \
	&& chmod -R 744 "${STEAM_SAVEDIR}"

ENV SERVERNAME=ServerName \
	PORT=<<SET_SERVER_PORT>> \
	QUERYPORT=<<SET_SERVER_QUERY_PORT>> \
	ADDITIONAL_ARGS=

# Switch to user
USER ${USER}

VOLUME ${STEAM_SAVEDIR}

WORKDIR ${HOME}

EXPOSE <<EXPOSED_NEEDED_PORTS>>

CMD ["bash", "entry.sh"]
