# Ruby Schema

Catch config mistakes before they reach production.

RubySchema provides JSON Schemas for common config files in Ruby projects so your editor can:

- validate YAML, JSON and TOML configs as you type
- auto-complete valid keys and values
- show inline documentation for each option

Works with any editor that supports JSON Schema via language servers (VS Code, Zed, Neovim, and more).

## Quick Start

### Rails (10 seconds)

Inject schema comments into supported Rails project config files:

```sh
bundle exec rails app:template LOCATION=https://www.rubyschema.org/rails.rb
```

You can run it again at any time to pick up new schemas.

![Example of auto-complete](https://github.com/user-attachments/assets/c8038624-4df5-4dd7-9fcf-787d5c8a5f71)

## Editor Setup

Prefer not to use the Rails template? Configure your editor once and use RubySchema across all projects.

### Nvim

Update your LSP config to include schema mappings for the files you use. For example, with [LazyVim](https://www.lazyvim.org), update or create `plugins/lsp-config.lua`.

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://www.rubyschema.org/honeybadger.json"] = "honeybadger.yml",
                ["https://www.rubyschema.org/i18n-tasks.json"] = "i18n-tasks.yml",
                ["https://www.rubyschema.org/lefthook.json"] = "lefthook.yml",
                ["https://www.rubyschema.org/mongoid.json"] = "mongoid.yml",
                ["https://www.rubyschema.org/pghero.json"] = "pghero.yml",
                ["https://www.rubyschema.org/rorvswild.json"] = "rorvswild.yml",
                ["https://www.rubyschema.org/rubocop.json"] = ".rubocop.yml",
                ["https://www.rubyschema.org/scout_apm.json"] = "scout_apm.yml",
                ["https://www.rubyschema.org/shoryuken.json"] = "shoryuken.yml",
                ["https://www.rubyschema.org/sidekiq.json"] = "sidekiq.yml",
                ["https://www.rubyschema.org/standard.json"] = ".standard.yml",
                ["https://www.rubyschema.org/vite.json"] = "vite.yml",
                ["https://www.rubyschema.org/i18n/locale.json"] = "locale/*.yml",
                ["https://www.rubyschema.org/kamal/deploy.json"] = "deploy.yml",
                ["https://www.rubyschema.org/packwerk/package.json"] = "package.yml",
                ["https://www.rubyschema.org/rails/cable.json"] = "cable.yml",
                ["https://www.rubyschema.org/rails/cache.json"] = "cache.yml",
                ["https://www.rubyschema.org/rails/database.json"] = "database.yml",
                ["https://www.rubyschema.org/rails/queue.json"] = "queue.yml",
                ["https://www.rubyschema.org/rails/recurring.json"] = "recurring.yml",
                ["https://www.rubyschema.org/rails/storage.json"] = "storage.yml",
              },
            },
          },
        },
      },
    },
  },
}
```

## Manual Setup

For YAML files, add this to the top of your file:

```yml
# yaml-language-server: $schema=<schema_url>

%YAML 1.1
---
```

For JSON files, add this property:

```json
{
  "$schema": "<schema_url>"
}
```

For TOML files, add this comment:

```toml
#:schema <schema_url>
```

You can find all available schemas below or in the [`dist` directory](./dist).

## Supported Config Files

| Name          | File                     | Schema URL                           |
| ------------- | ------------------------ | ------------------------------------ |
| Rails DB      | `database.yml`           | [`./dist/rails/database.json`](./dist/rails/database.json) |
| ActiveStorage | `storage.yml`            | [`./dist/rails/storage.json`](./dist/rails/storage.json) |
| SolidQueue    | `recurring.yml`          | [`./dist/rails/recurring.json`](./dist/rails/recurring.json) |
| SolidQueue    | `queue.yml`              | [`./dist/rails/queue.json`](./dist/rails/queue.json) |
| SolidCache    | `cache.yml`              | [`./dist/rails/cache.json`](./dist/rails/cache.json) |
| SolidCable    | `cable.yml`              | [`./dist/rails/cable.json`](./dist/rails/cable.json) |
| RuboCop       | `.rubocop.yml`           | [`./dist/rubocop.json`](./dist/rubocop.json) |
| Vite          | `vite.json`              | [`./dist/vite.json`](./dist/vite.json) |
| Kamal         | `deploy.yml`             | [`./dist/kamal/deploy.json`](./dist/kamal/deploy.json) |
| I18n          | `locales/{language}.yml` | [`./dist/i18n/locale.json`](./dist/i18n/locale.json) |
| Sidekiq       | `sidekiq.yml`            | [`./dist/sidekiq.json`](./dist/sidekiq.json) |
| RoRvsWild     | `rorvswild.yml`          | [`./dist/rorvswild.json`](./dist/rorvswild.json) |
| Standard      | `.standard.yml`          | [`./dist/standard.json`](./dist/standard.json) |
| Honeybadger   | `honeybadger.yml`        | [`./dist/honeybadger.json`](./dist/honeybadger.json) |
| Shoryuken     | `shoryuken.yml`          | [`./dist/shoryuken.json`](./dist/shoryuken.json) |
| Packwerk      | `package.yml`            | [`./dist/packwerk/package.json`](./dist/packwerk/package.json) |
| Lefthook      | `lefthook.yml`           | [`./dist/lefthook.json`](./dist/lefthook.json) |
| Lefthook      | `lefthook.json`          | [`./dist/lefthook.json`](./dist/lefthook.json) |
| Lefthook      | `lefthook.toml`          | [`./dist/lefthook.json`](./dist/lefthook.json) |
| Scout APM     | `scout_apm.yml`          | [`./dist/scout_apm.json`](./dist/scout_apm.json) |
| Mongoid       | `mongoid.yml`            | [`./dist/mongoid.json`](./dist/mongoid.json) |
| Pghero        | `pghero.yml`             | [`./dist/pghero.json`](./dist/pghero.json) |
| I18n-tasks    | `i18n-tasks.yml`         | [`./dist/i18n-tasks.json`](./dist/i18n-tasks.json) |

## Contributing

If a schema marks something valid as invalid (or misses a validation), please open an issue and include a small example config.

Schemas use JSON Schema draft-07 (the version supported by YAML language servers). They are committed directly in `dist/` and deployed to Cloudflare.

To test locally, replace the `$schema` URL with a relative path. In Zed, run `editor: restart language server` after schema changes.

## Why is it called RubySchema?

It is a little confusing: RubySchema provides JSON Schemas for YAML/JSON/TOML config files. The name reflects the audience (Ruby projects), not the schema format. If you need broader, language-agnostic coverage, check [JSON Schema Store](https://www.schemastore.org).
