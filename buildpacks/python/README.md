# Python Buildpack

Compatible apps:
- Python apps that use pip, python version in 3.6.14 3.7.11 3.8.11 3.9.6.
  When you build image, set the environment PIP_INDEX_URL PIP_EXTRA_INDEX_URL variable to set pip index url.

### Usage

```bash
pack build python-pip-project --env "PIP_INDEX_URL=xxx"--builder drycc/buildpacks:20
```