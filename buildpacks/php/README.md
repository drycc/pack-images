# PHP Buildpack

Compatible apps:
- PHP apps that use composer.
  Config extensions.json in project root dir. e.g.
```
tee > extensions.json < EOF
{
  "urls": [
      "http://pecl.php.net/get/oauth-2.0.7.tgz"
  ],
  "pecl": [
      "xdebug-3.0.4"
  ],
  "builtin": [
      "gd"
  ]
}
EOF
```

## Usage

```bash
pack build php-composer-project --builder drycc/buildpacks:20
```

## Version

You can generate a declared version of `.php-version` in the directory, php version in 7.3.31 7.4.24 8.0.11.

```
cat > ".php-version" <<EOL
x.y.z
EOL
```
