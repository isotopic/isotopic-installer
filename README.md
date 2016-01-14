This is the way I get a local copy from my website when I need to fix something.
I don't know how this could be useful to someone else, but this is what it does:

- Downloads the latest tar.gz from wordpress.org;
- Unpacks the files;
- Checks out the theme from github.com/isotopic/isotopic-theme
- Imports a basic .sql dump from the theme repo;
- Configures everything like wp_options, htaccess, etc.

Note: `install.sh` must be executed on the webroot (something like _www_, _public_html_, _htdocs_, etc)

```sh
$ cd /var/www/
$ git clone https://github.com/isotopic/isotopic-local.git isotopic && cd isotopic
$ chmod u+x install.sh
$ ./install.sh
```

After done, all installation files are removed (install.sh, .git, README.md) and pwd is changed to the theme location (.../wordpress/wp-content/themes/isotopic). From there, any changes must be commited normally. Some of the tasks requires gulp, like spritesheet generation or deploy with rsync. 

```sh
$ sudo npm install
$ gulp deploy
```
