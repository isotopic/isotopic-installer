__This is intended for personal use only.__


This shell script installs a local working copy for isotopic.com.br, through the following steps:

- Downloads the latest tar.gz from wordpress.org;
- Unpacks the files;
- Checks out the theme from github.com/isotopic/isotopic-theme
- Import a basic .sql dump from the theme repo;
- Configures everything like wp_options, htaccess, etc.


Note: Install.sh must be executed on the webroot (something like www, public_html, htdocs, etc)

```sh
$ cd /var/www/
$ git clone https://github.com/isotopic/isotopic-local.git isotopic && cd isotopic
$ chmod u+x install.sh
$ ./install.sh
```

When done, all installation files are removed (install.sh, .git, README.md) and the directory is changed to the theme location (.../wordpress/wp-content/themes/isotopic).

Deploys can be made after installing the package:

```sh
$ sudo npm install
$ gulp deploy
```
