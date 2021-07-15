# rust Buildpack

Compatible apps:
- Rust apps that use Cargo.
  Config .cargo/config in project. Replace update download source.

### Usage

```bash
pack build rust-cargo-project --builder drycc/buildpacks:20
```