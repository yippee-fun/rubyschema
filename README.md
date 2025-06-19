# Ruby Schema

Ruby schema is a collection of schemas for the YAML and JSON configuration in common Ruby gems. This gives you auto-complete and validation for these YAML files in text editors that support the YAML language server.

![Example of auto-complete](https://github.com/user-attachments/assets/c8038624-4df5-4dd7-9fcf-787d5c8a5f71)

Just add the `yaml-language-server` comment to the top of your YAML files.

### Rails

To install all Rails schemas, run:

```
bundle exec rails app:template LOCATION=https://www.rubyschema.org/rails.rb
```

#### `database.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/database.json
```

#### `storage.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/storage.json
```

#### `recurring.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/recurring.json
```

#### `queue.yml`

Planned

#### `cache.yml`

Planned

#### `cable.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/cable.json
```

### Rubocop

#### `rubocop.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rubocop.json
```

### Vite

#### `vite.json`

```json
{
  "$schema": "https://www.rubyschema.org/vite.json"
}
```

### Kamal

#### `deploy.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/kamal/deploy.json
```

### I18n

#### `locales/{language}.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/i18n/locale.json
```

## Contributing

If you find an issue with a schema, for example it says that something is invalid when it isn’t, please open an issue with an example.

The schemas are written in JSON Schema version 7 (since that’s the version that YAML LSP supports). They are currently committed directly to the `dist` folder, which is deployed automatically to Cloudflare.

## Why is it called RubySchema?

I know it’s confusing. RubySchema provides JSON Schemas for YAML files. 🤯 The name reflects the purpose of providing schemas specifically for the Ruby community, where a lot of Ruby gems rely on YAML/JSON configuration files. There’s another project called [JSON Schema Store](https://www.schemastore.org) with a significantly wider scope.
