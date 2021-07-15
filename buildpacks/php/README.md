# PHP Buildpack

Compatible apps:
- PHP apps that use composer, php version in 7.3.29 7.4.21 8.0.8
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

### Usage

```bash
pack build php-composer-project --builder drycc/buildpacks:20
```