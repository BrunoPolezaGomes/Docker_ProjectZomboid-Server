#!/bin/bash

cd ${STEAMAPPDIR}

#########################################
#                                       #
# Att se o FORCEUPDATE estiver definido #
#                                       #
#########################################

if [ "${FORCEUPDATE}" == "1" ]; then
  echo "FORCEUPDATE variável está definida, então o servidor será atualizado agora"
  bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" +login anonymous +app_update "${STEAMAPPID}" validate +quit
fi


######################################
#                                    #
# Process argumentos em variáveis    #
#                                    #
######################################
ARGS=""

# Defina a memória do servidor. As unidades são aceitas (1024m=1Gig, 2048m=2Gig, 4096m=4Gig)
if [ -n "${MEMORY}" ]; then
  ARGS="${ARGS} -Xmx${MEMORY} -Xms${MEMORY}"
fi

# Opção para executar um Soft Reset
if [ "${SOFTRESET}" == "1" ] || [ "${SOFTRESET,,}" == "true" ]; then
  ARGS="${ARGS} -Dsoftreset"
fi

# Fim dos argumentos Java
ARGS="${ARGS} -- "

# Desativa a integração do Steam no servidor.
# - Padrão: Habilitado
if [ "${NOSTEAM}" == "1" ] || [ "${NOSTEAM,,}" == "true" ]; then
  ARGS="${ARGS} -nosteam"
fi

# Define o caminho para o diretório do cache de dados do jogo.
# - Padrão: ~/Zomboid
# - Exemplo: /server/Zomboid/data
if [ -n "${CACHEDIR}" ]; then
  ARGS="${ARGS} -cachedir=${CACHEDIR}"
fi

# Opção para controlar de onde os mods são carregados e a ordem. Qualquer uma das 3 palavras-chave pode ser deixada de fora e pode aparecer em qualquer ordem.
# - Default: workshop,steam,mods
# - Example: mods,steam
if [ -n "${MODFOLDERS}" ]; then
  ARGS="${ARGS} -modfolders ${MODFOLDERS}"
fi

# Launches the game in debug mode.
# - Default: Disabled
if [ "${DEBUG}" == "1" ] || [ "${DEBUG,,}" == "true" ]; then
  ARGS="${ARGS} -debug"
fi

# Opção para ignorar o prompt de digitação de senha ao criar um servidor.
# Esta opção é obrigatória na primeira inicialização ou será solicitada no console e a inicialização falhará.
# Uma vez iniciado e os dados criados, podem ser removidos sem problemas.
# É recomendável removê-lo, porque o servidor registra os argumentos em texto não criptografado, portanto, a senha do administrador será enviada para fazer login a cada inicialização.
if [ -n "${ADMINPASSWORD}" ]; then
  ARGS="${ARGS} -adminpassword ${ADMINPASSWORD}"
else
  # Se ADMINPASSWORD não estiver definido, use o nome padrão
  ADMINPASSWORD='P@ssw0rd'
fi

# SERVERNAME
if [ -n "${SERVERNAME}" ]; then
  ARGS="${ARGS} -servername ${SERVERNAME}"
else
  # Se SERVERNAME não estiver definido, use o nome padrão
  SERVERNAME="MONGA_PZServer"
fi

# Se preset for definido, o arquivo de configuração será gerado quando ele não existir ou SERVERPRESETREPLACE for definido como True.
if [ -n "${SERVERPRESET}" ]; then
  # Se o arquivo predefinido não existir, mostre um erro e saia
  if [ ! -f "${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua" ]; then
    echo "*** ERRO: a predefinição ${SERVERPRESET} não existe. Corrija a configuração antes de iniciar o servidor ***"
    exit 1
  # Se os arquivos SandboxVars não existirem ou a substituição for verdadeira, copie o arquivo
  elif [ ! -f "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua" ] || [ "${SERVERPRESETREPLACE,,}" == "true" ]; then
    echo "*** INFO: Novo servidor será criado usando o preset ${SERVERPRESET} ***"
    echo "*** Copiando arquivo predefinido de \"${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua\" to \"${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua\" ***"
    mkdir -p "${HOMEDIR}/Zomboid/Server/"
    cp -nf "${STEAMAPPDIR}/media/lua/shared/Sandbox/${SERVERPRESET}.lua" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
    sed -i "1s/return.*/SandboxVars = \{/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
    # Remova o retorno do carro
    dos2unix "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
    # Vi que o arquivo é criado em modo de execução (755). Altere o modo de arquivo por motivos de segurança.
    chmod 644 "${HOMEDIR}/Zomboid/Server/${SERVERNAME}_SandboxVars.lua"
  fi
fi

# Option to handle multiple network cards. Example: 127.0.0.1
if [ -n "${IP}" ]; then
  ARGS="${ARGS} ${IP} -ip ${IP}"
fi

# Set the DefaultPort for the server. Example: 16261
if [ -n "${PORT}" ]; then
  ARGS="${ARGS} -port ${PORT}"
else
  # Se PORT não estiver definido, use o nome padrão
  PORT="16261"
fi

# Option to enable/disable VAC on Steam servers. On the server command-line use -steamvac true/false. In the server's INI file, use STEAMVAC=true/false.
if [ -n "${STEAMVAC}" ]; then
  ARGS="${ARGS} -steamvac ${STEAMVAC,,}"
fi

# Os servidores Steam requerem duas portas adicionais para funcionar (acho que ambas são portas UDP, mas no steamcmd diz que pode precisar de TCP).
# Estes são adicionais à configuração DefaultPort=. Estes podem ser especificados de duas maneiras:
# - No arquivo INI do servidor como SteamPort1= e SteamPort2=.
# - Usando variáveis STEAMPORT1 e STEAMPORT2.
if [ -n "${STEAMPORT1}" ]; then
  ARGS="${ARGS} -steamport1 ${STEAMPORT1}"
fi
if [ -n "${STEAMPORT2}" ]; then
  ARGS="${ARGS} -steamport2 ${STEAMPORT1}"
fi

if [ -n "${PASSWORD}" ]; then
	sed -i "s/Password=.*/Password=${PASSWORD}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
fi

if [ -n "${MOD_IDS}" ]; then
 	echo "*** INFORMAÇÕES: Mods encontrados, incluindo ${MOD_IDS} ***"
	sed -i "s/Mods=.*/Mods=${MOD_IDS}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
else
  # Se MOD_IDS não estiver definido, use o nome padrão
  MOD_IDS='2931602698,2931602698'
fi

if [ -n "${WORKSHOP_IDS}" ]; then
 	echo "*** INFORMAÇÕES: IDs de oficinas encontradas, incluindo ${WORKSHOP_IDS} ***"
	sed -i "s/WorkshopItems=.*/WorkshopItems=${WORKSHOP_IDS}/" "${HOMEDIR}/Zomboid/Server/${SERVERNAME}.ini"
else
  # Se WORKSHOP_IDS não estiver definido, use o nome padrão
  WORKSHOP_IDS="2875848298,2849247394,2923439994,2859296947,2859296947,2859296947"
fi


# Correção de um bug em start-server.sh que causa o não pré-carregamento de uma biblioteca:
# ERRO: ld.so: objeto 'libjsig.so' de LD_PRELOAD não pode ser pré-carregado (não pode abrir arquivo de objeto compartilhado): ignorado.
export LD_LIBRARY_PATH="${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}"

## Fixe as permissões nas pastas data e workshop
chown -R 1000:1000 /home/steam/pz-dedicated/steamapps/workshop /home/steam/Zomboid

su - steam -c "export LD_LIBRARY_PATH=\"${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}\" && cd ${STEAMAPPDIR} && pwd && ./start-server.sh ${ARGS}"
