# Docker Servidor dedicado MONGA Projeto Zomboid

Docker Servidor dedicado do Project Zombie usando o SteamCMD.
https://hub.docker.com/r/lorthe/monga_projectzomboid

## Docker RUN Commands
```sh
# Baixar imagem Docker
docker push lorthe/projectzomboidserver:latest
# Excluir Imagem para re reploy
docker rm -f monga_projectzomboid

# Criar container com as variaveis
docker run -d -t -i -e SERVERNAME='MONGA_PZServer' -p 16261:16265 \
-e ADMINPASSWORD='Password@123' \
-e PORT='16261'  \
-e FORCEUPDATE='' \
-e MOD_IDS='2931602698,2931602698' \
-e WORKSHOP_IDS='2875848298,2849247394,2923439994,2859296947,2859296947,2859296947' \
--name monga_projectzomboid lorthe/monga_projectzomboid:latest

# Iniciar Containter
docker start monga_projectzomboid
```
## Variáveis ​​ambientais
Dockerfile variáveis de ambiente:
`ADMINPASSWORD:` Define ou altera a senha do administrador.

`CACHEDIR:` Defina a pasta onde os dados serão armazenados.

`DEBUG:` Ativa o modo de depuração no servidor

`FORCEUPDATE:` Força uma atualização do servidor a cada inicialização.

`IP:` Defina o IP da interface onde o servidor irá escutar. Por padrão, todas as interfaces.

`MEMORY:` Quantidade de memória a ser usada no servidor JVM (unidades podem ser usadas, por exemplo 2048m). Por padrão 8096m.

`MODFOLDERS` Pastas de mods a serem usadas para carregar os mods do jogo. As opções permitidas são workshop, steam e mods. As opções devem ser separadas por vírgula, por exemplo: workshop,steam,mods

`NOSTEAM:` modo NoSteam

`PORT:` Defina a porta do servidor. Padrão 16261

`SERVERNAME:` Nome do servidor

`SERVERPRESET:` Defina a predefinição padrão dos novos servidores. Se não for definido, o padrão é apocalipse. As opções permitidas são Apocalypse, Beginner, Builder, FirstWeek, SixMonthsLater, Survival e Survivor.

`SERVERPRESETREPLACE:` Substitua o preset do servidor pelo definido pela variável SERVERPRESET. Por padrão, false para evitar a substituição de configurações customizadas assim que o servidor for iniciado.

`SOFTRESET:` Executa um soft reset no servidor. Mais informações na seção Soft Reset.

`STEAMPORT1 & STEAMPORT2:` Define as duas portas adicionais necessárias para o vapor funcionar. Eu acho que essas portas são UDP, mas também podem ser TCP.

`STEAMVAC:` Habilita ou desabilita a proteção SteamVac no servidor

`WORKSHOP_IDS:` Lista separada por ponto e vírgula de IDs de Oficina para instalar no servidor

`MOD_IDS:` Lista separada por ponto e vírgula de Mod IDs para instalar no servidor


## Reinicialização Suave
A reinicialização suave executará as seguintes tarefas:
* Remove itens do chão.
* Remove itens dos contêineres e os substitui por novos itens. Isso inclui contêineres feitos por jogadores.
* Remove cadáveres e jogadores zumbificados.
* Reseta os zumbis.
* Remove respingos de sangue.
* Redefine os alarmes do prédio.
* Redefine o relógio do jogo. Não tenho certeza se isso é redefinido para o dia 1, mas a postagem original do blog sugere que sim. Então isso traria água e eletricidade de volta. Supondo que as configurações do servidor os tenham * disponíveis no dia 1.
* Edifícios feitos por jogadores não serão excluídos.
* Os inventários dos jogadores não serão zerados.

## Portas necessárias
As portas necessárias estão documentadas no [wiki oficial](https://pzwiki.net/wiki/Dedicated_Server#Forwarding_Required_Ports)

### Portas dos clientes Steam
Esta porta é utilizada pelos clientes Steam para se conectar com o servidor, portanto deve ser aberta no firewall e configurada no NAT.
* 8766 UDP
* 8767 UDP
* 16261 UDP (configurável)

### Portas de clientes não Steam
Esta porta é utilizada pelos clientes No Steam para se conectar com o servidor, portanto deve ser aberta no firewall e configurada no NAT.
* 8766 UDP
* 8767 UDP
* 16261 UDP (configurável)
* 16262 - 16272 TCP (a faixa depende da porta acima e dos slots dos clientes)

