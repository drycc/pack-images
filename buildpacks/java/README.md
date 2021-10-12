# rust Buildpack

Compatible apps:
- Java apps

## Usage

```bash
pack build java-project --builder drycc/buildpacks:20
```

## Version

You can generate a declared version of `.jdk-version` in the directory.

```
cat > ".jdk-version" <<EOL
x.y.z
EOL