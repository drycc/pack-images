# Rust Buildpack

Compatible apps:
- Rust apps that use Cargo.
  Config .cargo/config in project. Replace update download source.

## Usage

```bash
pack build rust-cargo-project --builder drycc/buildpacks:20
```

## Version

You can generate a declared version of `.rust-version` in the directory.

```
cat > ".rust-version" <<EOL
x.y.z
EOL