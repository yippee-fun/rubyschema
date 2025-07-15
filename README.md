# Ruby Schema

YAML is an incredibly difficult language for me. Between significant whitespace, bare strings and ambiguous booleans, I find it quite impossible to follow. And although the language has improved over time, 15 years since the v1.2 spec was released, Ruby is still stuck on the 1.1 spec.

Most YAML configs need to be _just so_ in order to work properly yet they are often unspecified, poorly documented and lack proper validation.

Despite all this, YAML is the primary language for Ruby Gem configs and there's nothing you or I can do about it.

The good news is, modern text editors support language servers and there's a fantastic language server for YAML files. All we need to do is tell the language server which version of YAML we're using (1.1) and give it a data schema.

Ruby schema is a collection of JSON schemas for common Ruby gems. With these schemas, we can now enjoy auto-complete, validation and inline documentation right in our YAML files.

![Example of auto-complete](https://github.com/user-attachments/assets/c8038624-4df5-4dd7-9fcf-787d5c8a5f71)

## Rails

To install all the Ruby schemas in a Rails, you can run:

```
bundle exec rails app:template LOCATION=https://www.rubyschema.org/rails.rb
```

You can run it again for updates as new schemas are released.

## Editor Setup

Alternatively, you may configure your editor once to use the available schemas so all your Rails projects can use them.

### Nvim

Update your LSP Config to include the custom YAML schemas for the respective files. For example, using [LazyVim](www.lazyvim.org) update or create your `plugins/lsp-config.lua`.

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
                ["https://www.rubyschema.org/rails/recurring.json"] = "recurring.yml", ["https://www.rubyschema.org/rails/storage.json"] = "storage.yml",
              },
            },
          },
        },
      },
    },
  },
}
```

## Manual

YFor YAML files, add this to the top of your file:

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

You can find a list of available schemas below or in the [dist directory](./dist)

## Available Schemas

 | Name | File  | Schema URL |
|------|-----------|------------|
| Rails DB | `database.yml` | `https://www.rubyschema.org/rails/database.json` |
| ActiveStorage | `storage.yml` | `https://www.rubyschema.org/rails/storage.json` |
| SolidQueue  | `recurring.yml` | `https://www.rubyschema.org/rails/recurring.json` |
| SolidQueue | `queue.yml` | `https://www.rubyschema.org/rails/queue.json` |
| SolidCache | `cache.yml` | `https://www.rubyschema.org/rails/cache.json` |
| SolidCable | `cable.yml` | `https://www.rubyschema.org/rails/cable.json` |
| Rubocop | `rubocop.yml` | `https://www.rubyschema.org/rubocop.json` |
| Vite | `vite.json` | `https://www.rubyschema.org/vite.json` |
| Kamal | `deploy.yml` | `https://www.rubyschema.org/kamal/deploy.json` |
| I18n | `locales/{language}.yml` | `https://www.rubyschema.org/i18n/locale.json` |
| Sidekiq | `sidekiq.yml` | `https://www.rubyschema.org/sidekiq.json` |
| RoRvsWild | `rorvswild.yml` | `https://www.rubyschema.org/rorvswild.json` |
| Standard | `standard.yml` | `https://www.rubyschema.org/standard.json` |
| Honeybadger | `honeybadger.yml` | `https://www.rubyschema.org/honeybadger.json` |
| Shoryuken | `shoryuken.yml` | `https://www.rubyschema.org/shoryuken.json` |
| Packwerk | `package.yml` | `https://www.rubyschema.org/packwerk/package.json` |
| Lefthook | `lefthook.yml` | `https://www.rubyschema.org/lefthook.json` |
| Lefthook | `lefthook.json` | `https://www.rubyschema.org/lefthook.json` |
| Lefthook | `lefthook.toml` | `https://www.rubyschema.org/lefthook.json` |
| Scout AMP | `scout_apm.yml` | `https://www.rubyschema.org/scout_apm.json` |
| Mongoid | `mongoid.yml` | `https://www.rubyschema.org/mongoid.json` |
| Pghero | `pghero.yml` | `https://www.rubyschema.org/pghero.json` |
| I18n-tasks | `i18n-tasks.yml` | `https://www.rubyschema.org/i18n-tasks.json` |


## Contributing

If you find an issue with a schema, for example it says that something is invalid when it isn't, please open an issue with an example.

The schemas are written in JSON Schema version 7 (since that's the version that YAML LSP supports). They are currently committed directly to the `dist` folder, which is deployed automatically to Cloudflare.

You can test the schemas locally by replacing the `$schema` URL with a relative path. In Zed, you need to run the `editor: restart language server` command each time you make changes to the schema.

## Why is it called RubySchema?

I know it's confusing. RubySchema provides JSON Schemas for YAML files. 🤯 The name reflects the purpose of providing schemas specifically for the Ruby community, where a lot of Ruby gems rely on YAML/JSON configuration files. There's another project called [JSON Schema Store](https://www.schemastore.org) with a significantly wider scope.
