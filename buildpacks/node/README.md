# Go Buildpack

Compatible apps:
- Nodejs apps that use npm.

### Usage

```bash
pack build nodejs_npm_project --builder drycc/buildpacks:20
```

## Version

You can generate a declared version of `.node-version` in the directory.

```
cat > ".node-version" <<EOL
x.y.z
EOL