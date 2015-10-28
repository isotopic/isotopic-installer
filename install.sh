#!/bin/bash


clear

MYSQL_USER=''
MYSQL_PASSWD=''
DATABASE_NAME='isotopic_'$(date +%s)
DUMP_FILE=''
WORDPRESS_SRC='https://wordpress.org/wordpress-4.3.1.tar.gz'
THEME_SRC='https://github.com/isotopic/isotopic-theme.git'
HOME='http://localhost/'${PWD##*/}
CYAN="\033[0;33m"
WHITE="\033[1;37m"
RED="\033[1;31m"
RESET="\033[0m"



function intro {

	cat <<-HERE_EOL
	$(echo -e "${CYAN}")
	 -------------------------------------------------------------
	     ____           __              _     
	    /  _/________  / /_____  ____  (_)____
	    / // ___/ __ \/ __/ __ \/ __ \/ / ___/
	  _/ /(__  ) /_/ / /_/ /_/ / /_/ / / /__  
	 /___/____/\____/\__/\____/ .___/_/\___/   LOCAL DEV INSTALLER
	                         /_/              
	
	 Ambiente de desenvolvimento local para o tema do isotopic.
	 A instalação consiste no download e configuração do wordpress,
	 checkout do tema no git e a importação do dump básico mysql.
	 Requisitos de sistema:
	 Apache, PHP, MySQL, git (mysql e git adicionados ao PATH);
	 --------------------------------------------------------------
	$(echo -e "${RESET}")
	HERE_EOL

}




#Checa se mysql e git estão no PATH, e se mysqld e httpd estão rodando
function requeriments_check {

	ERRORS=0

	printf ' Checando requerimentos...\n'

	if hash mysql 2>/dev/null; then
        printf "\n mysql client:$WHITE ok$RESET"
    else
    	printf "\n mysql client:$RED fail$RESET"
        ERRORS=1
    fi

	if hash git 2>/dev/null ; then
		printf "\n git client:$WHITE ok$RESET"
	else
		printf "\n git client:$RED fail$RESET"
	    ERRORS=1
	fi

	if ps ax | grep -v grep | grep httpd > /dev/null  ||  ps ax | grep -v grep | grep apache2 > /dev/null  ; then
		printf "\n httpd service:$WHITE ok$RESET"
	else
		printf "\n httpd service:$RED fail$RESET"
	    ERRORS=1
	fi

	if ps ax | grep -v grep | grep mysqld > /dev/null ; then
		printf "\n mysqld service:$WHITE ok$RESET"
	else
		printf "\n mysqld service:$RED fail$RESET"
	    ERRORS=1
	fi

	printf '\n'

	if [ $ERRORS -gt 0 ] ; then
		printf '\n\n'
		exit 1;
	fi

}


function confirm_proceed {

	cat <<-HERE_EOL
	
	 A url a ser configurada no site será: $(echo -e "${WHITE}$HOME${RESET}")

	 O nome do banco de dados será: $(echo -e "${WHITE}$DATABASE_NAME${RESET}")

	HERE_EOL


	printf " > Continuar? (y/n) "
	read yes_no

	if [[ ! $yes_no =~ ^[YySs]$ ]]; then
		printf '\n  Bye\n\n'
	    exit 1
	else
		printf '\n'	
	fi

}


function get_mysql_creds {

	read -p " > Digite o usuário mysql: " MYSQL_USER
	printf '\n'
	read -s -p " > Digite a senha mysql: " MYSQL_PASSWD

}




function get_wordpress {

	printf '\n\n Download do wordpress...\n\n'
	curl $WORDPRESS_SRC | tar -xz

	if [ $? -ne 0 ]
	then
	    printf '\n Curl falhou.'
	    exit 1
	else
	    printf '\n'
	fi

}




function config_wordpress {

	printf '\n\n Configurando wordpress...'

	cp wordpress/wp-config-sample.php wordpress/wp-config.php

	sed -i '' 's/database_name_here/'"$DATABASE_NAME"'/g' wordpress/wp-config.php
	sed -i '' 's/username_here/'"$MYSQL_USER"'/g'   wordpress/wp-config.php
	sed -i '' 's/password_here/'"$MYSQL_PASSWD"'/g' wordpress/wp-config.php

	cp wordpress/index.php index.php
	sed -i '' 's/wp-blog-header.php/wordpress\/wp-blog-header.php/g' index.php

echo "# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /${PWD##*/}/
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /${PWD##*/}/index.php [L]
</IfModule>

# END WordPress" > .htaccess

	if [ $? -ne 0 ]
	then
	    printf '\nConfiguração falhou.'
	    exit 1
	else
	    printf ": $WHITE ok$RESET\n"
	fi

}




function get_theme_repo {

	printf '\n\n Clonando repositório do tema...\n\n'
	git clone $THEME_SRC wordpress/wp-content/themes/isotopic

}



function choose_mysql_dump() {


	dump_dir=wordpress/wp-content/themes/isotopic/*.sql


	if ls $dump_dir 1> /dev/null 2>&1; then

		dump_files=($(ls -d $dump_dir))

		length=${#dump_files[@]}

		if [ $length -eq 1 ]
		then

			DUMP_FILE=$(ls $dump_dir)

		elif [ $length -gt 1 ]
		then

			printf '\n Existe mais de um arquivo .sql no repositório.\n\n'	

			for (( i=0; i<${length}; i++ ));
			do
			  echo " [$i] ${dump_files[$i]}"
			done

		 	printf "\n > Digite o índice do arquivo a ser importado e pressione enter: "
			read index
			DUMP_FILE=${dump_files[$index]}

		else

		  exit 1

		fi


	else

	    printf "\n $RED Não há nenhum arquivo .sql no diretório do tema$RESET\n\n "
	    exit 1;

	fi

}




function import_mysql_dump {

	printf "\n Arquivo .sql a ser importado:$WHITE $DUMP_FILE $RESET\n"

	echo "create database $DATABASE_NAME" | mysql -u$MYSQL_USER -p$MYSQL_PASSWD

	mysql -u$MYSQL_USER -p$MYSQL_PASSWD $DATABASE_NAME < $DUMP_FILE

}


function config_mysql_options {

	mysql -u$MYSQL_USER -p$MYSQL_PASSWD --database $DATABASE_NAME -e "UPDATE wp_options SET option_value = '$HOME/wordpress' WHERE option_name='siteurl'"
	mysql -u$MYSQL_USER -p$MYSQL_PASSWD --database $DATABASE_NAME -e "UPDATE wp_options SET option_value = '$HOME' WHERE option_name='home'"

}



function finish {

	printf "\n Importação completada. Site rodando em :$WHITE $HOME $RESET\n"

	if [ -d ".git" ]; then
	  rm -rf ".git"
	fi

	if [ -e "install.sh" ]; then
	  rm "install.sh"
	fi

	if [ -e ".gitignore" ]; then
	  rm ".gitignore"
	fi

	if [ -e "README.md" ]; then
	  rm "README.md"
	fi

	

}





intro 

requeriments_check

confirm_proceed

get_mysql_creds

get_wordpress

config_wordpress

get_theme_repo

choose_mysql_dump

import_mysql_dump

config_mysql_options

finish




