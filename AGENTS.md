# AGENTS.md

## Project Overview

RubySchema is a collection of JSON schemas for common Ruby gem configuration files. These schemas enable auto-complete, validation, and inline documentation in editors via the YAML language server. Schemas are committed directly to the `dist/` folder and deployed to Cloudflare at `https://www.rubyschema.org/`.

## Schema Conventions

- All schemas use **JSON Schema draft-07** (`https://json-schema.org/draft-07/schema#`), since that's what the YAML language server supports.
- Every schema must include a `$schema` and `$id` field. The `$id` should be `https://www.rubyschema.org/<name>.json`.
- Use `markdownDescription` (not `description`) for documentation strings — this is what editors render.
- Include `default`, `examples`, and `type` where appropriate.
- Use `definitions` for reusable sub-schemas and reference them with `$ref`.
- Schemas should only be created for **project-level** configuration files, not global/user-level configs (e.g. `~/.yard/config` would not belong here).

## File Structure

- `dist/` — JSON schema files and the `rails.rb` template. This is the deployed directory.
- `dist/rails.rb` — A Rails app template that injects schema comments into project config files. Schemas added here must correspond to files that live within a Rails project directory (paths start with `./`).
- `test/fixtures/` — Example config files organised by gem name, used for testing schemas.

## Adding a New Schema

1. Create the schema as `dist/<name>.json` (or `dist/<name>/<subname>.json` for namespaced schemas).
2. If the config file lives inside a Rails project, add a mapping entry to the appropriate hash in `dist/rails.rb` (`yaml_schemas`, `json_schemas`, or `toml_schemas`). Keep entries in alphabetical order by path.
3. Add test fixtures under `test/fixtures/<name>/`.

## Running Tests

Tests use **Minitest** and validate every schema against JSON Schema draft-07 and check that all fixture files pass validation against their corresponding schema.

```sh
bundle exec rake test
```

This runs all tests in `test/`. You can also run a single test file directly:

```sh
bundle exec ruby test/schema_test.rb
```

## Code Style

- Ruby code follows Rubocop with the configuration in `.rubocop.yml` (inherits from `https://www.goodcop.style/base.yml`), targeting Ruby 3.4.
- JSON schemas should be formatted with 2-space indentation.
