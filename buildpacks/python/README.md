# Python Buildpack

Compatible apps:
- Python apps that use pip.
  When you build image, set the environment PIP_INDEX_URL PIP_EXTRA_INDEX_URL variable to set pip index url.

## Usage

```bash
pack build python-pip-project --env "PIP_INDEX_URL=xxx" --builder drycc/buildpacks:20
```

## Version

You can generate a declared version of `.python-version` in the directory, python version in 3.6.15 3.7.12 3.8.12 3.9.7 3.10.0.

```
cat > ".python-version" <<EOL
x.y.z
EOL
```