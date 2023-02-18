# Contêiner de servidor dedicado do Projeto Zomboid

Este Dockerfile baixa o servidor dedicado do Project Zombie usando o SteamCMD. Permitirá implantar com facilidade um servidor em Kubernetes, Docker...

A imagem pronta para usar está disponível aqui:

https://hub.docker.com/r/lorthe/monga_projectzomboid

## Variáveis ​​ambientais

Este dockerfile converte algumas variáveis env em argumentos no comando do servidor, permitindo configurá-lo. A imagem suporta as seguintes variáveis de ambiente:

`ADMINPASSWORD:` Define ou altera a senha do administrador. É obrigatório na primeira inicialização ou falhará. Eu recomendo removê-lo assim que o servidor for iniciado porque o servidor registra todos os argumentos em texto não criptografado (se não se importar, você pode deixá-lo).

`CACHEDIR:` Defina a pasta onde os dados serão armazenados. Por padrão, o servidor armazena os dados na pasta Zomboid no diretório inicial (/home/steam/Zomboid). Recomenda-se armazenar esses dados em um volume persistente para manter o estado do servidor.

`DEBUG:` Ativa o modo de depuração no servidor

`FORCEUPDATE:` Força uma atualização do servidor a cada inicialização. Esse processo pode ser lento se a imagem for antiga.

`IP:` Defina o IP da interface onde o servidor irá escutar. Por padrão, todas as interfaces.

`MEMORY:` Quantidade de memória a ser usada no servidor JVM (unidades podem ser usadas, por exemplo 2048m). Por padrão 8096m.

`MODFOLDERS`: Pastas de mods a serem usadas para carregar os mods do jogo. As opções permitidas são workshop, steam e mods. As opções devem ser separadas por vírgula, por exemplo: workshop,steam,mods

`NOSTEAM:` Inicia o servidor no modo NoSteam, permitindo que usuários não Steam se conectem.

`PORT:` Defina a porta do servidor. Por padrão 16261

`SERVERNAME:` Defina o nome do servidor, o que permite que você tenha várias versões do servidor. Alterar o nome criará um novo servidor de dados, portanto, o progresso atual não estará disponível. Também não será perdido, apenas revertendo a alteração do nome do servidor irá carregá-lo novamente.

`SERVERPRESET:` Defina a predefinição padrão dos novos servidores. Se não for definido, o padrão é apocalipse. As opções permitidas são Apocalypse, Beginner, Builder, FirstWeek, SixMonthsLater, Survival e Survivor.

`SERVERPRESETREPLACE:` Substitua o preset do servidor pelo definido pela variável SERVERPRESET. Por padrão, false para evitar a substituição de configurações customizadas assim que o servidor for iniciado.

`SOFTRESET:` Executa um soft reset no servidor. Mais informações na seção Soft Reset.

`STEAMPORT1 & STEAMPORT2:` Define as duas portas adicionais necessárias para o vapor funcionar. Eu acho que essas portas são UDP, mas também podem ser TCP.

`STEAMVAC:` Habilita ou desabilita a proteção SteamVac no servidor

`WORKSHOP_IDS:` Lista separada por ponto e vírgula de IDs de Oficina para instalar no servidor

`MOD_IDS:` Lista separada por ponto e vírgula de Mod IDs para instalar no servidor

Os mods serão instalados na inicialização do segundo servidor
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

Removendo os seguintes arquivos na pasta de dados do servidor (ToDo: tenho que pesquisar os arquivos equivalentes na versão moderna):

* todos os arquivos zombie_X_Y.bin
* map_t.bin
* map_meta.bin
* reanimado.bin

Atualmente não está funcionando corretamente e fará com que o servidor trave quando estiver ativo. Além disso, os pontos acima não são executados, portanto, nada será alterado no servidor.

## Portas necessárias

As portas necessárias estão documentadas no [wiki oficial](https://pzwiki.net/wiki/Dedicated_Server#Forwarding_Required_Ports)

Por enquanto as portas são as seguintes, mas pode mudar.

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

### Notas

* A porta 16261 pode ser alterada usando a variável de ambiente PORT. Isso afetará o intervalo de portas TCP, alterando-o para a próxima porta. Por exemplo, se PORT for definido como 12234, o intervalo TCP será 12234 - 12244.
* O intervalo de portas TCP é usado pelos clientes, portanto, cada slot de cliente precisará de uma porta. Se o seu servidor planeja hospedar 50 clientes, você precisará abrir 50 portas no firewall/nat... (16262 - 16312).
* O Wiki diz que as portas Non Steam devem ser para clientes não Steam, mas estou usando o cliente Steam e essas portas também são usadas.

## Como usar a imagem
Para configurar o servidor, você pode usar o programa docker-compose:

* Copie o .env.template para .env e edite-o com as configurações desejadas. A única variável obrigatória é ADMINPASSWORD e apenas na primeira vez que o servidor é executado (uma vez iniciado pelo menos uma vez, pode ser removido). As outras variáveis são opcionais.
* Execute o comando `docker-compose up -d` para iniciar o servidor.

## Pasta de scripts

Nas pastas de scripts existem três scripts:

* entry.sh: O script usado na imagem para iniciar o servidor
* update_forum.sh: Verifique as postagens no fórum para atualizações e crie uma nova imagem se houver uma nova versão. Este script foi feito porque parece que a página oficial não atualiza a versão assim que sai.
* uodate_web.sh: Verifique a versão na página oficial e crie uma nova imagem se existir uma nova versão

danixu86/project-zomboid-dedicated-server
