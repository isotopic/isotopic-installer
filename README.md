# isotopic-local

Instalador de versão local para manutenção do isotopic.com.br

Install.sh deve ser executado em um diretório no webroot.
Ex.:



```sh
$ cd /var/www/

$ git clone https://github.com/isotopic/isotopic-local.git

$ cd isotopic-local

$ chmod u+x install.sh

$ ./install.sh
```


Após terminada a execução, os arquivos de instalação (install.sh, .git, README.md) são removidos e as edições no tema devem ser comitadas no repositório do próprio tema.

Deploy deve ser feito com rsync ou rsync-wrapper após o _sudo npm install_.
