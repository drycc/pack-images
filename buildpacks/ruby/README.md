# Ruby Buildpack

Compatible apps:
- Ruby apps that use Bundler.

## Usage

```bash
pack build ruby-bundler-project --builder drycc/buildpacks:20
```

## Version

You can generate a declared version of `.ruby-version` in the directory, ruby version in 2.6.8 2.7.4 3.0.2.

```
cat > ".ruby-version" <<EOL
x.y.z
EOL