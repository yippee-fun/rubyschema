# Ruby Schema

YAML is an incredibly difficult language for me. Between significant whitespace, bare strings and ambiguous booleans, I find it quite impossible to follow. And although the language has improved over time, 15 years since the v1.2 spec was released, Ruby is still stuck on the 1.1 spec.

Most YAML configs need to be _just so_ in order to work properly yet they are often unspecified, poorly documented and lack proper validation.

Despite all this, YAML is the primary language for Ruby Gem configs and there’s nothing you or I can do about it.

The good news is, modern text editors support language servers and there’s a fantastic language server for YAML files. All we need to do is tell the language server which version of YAML we’re using (1.1) and give it a data schema, specified as a JSON schema.

Ruby schema is a collection of JSON schemas for common Ruby gems. With these schemas, we can now enjoy auto-complete, validation and inline documentation right in our YAML files.

![Example of auto-complete](https://github.com/user-attachments/assets/c8038624-4df5-4dd7-9fcf-787d5c8a5f71)

### Rails

To install all the Ruby schemas in a Rails, you can run:

```
bundle exec rails app:template LOCATION=https://www.rubyschema.org/rails.rb
```

#### `database.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/database.json

%YAML 1.1
---
```

#### `storage.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/storage.json

%YAML 1.1
---
```

#### `recurring.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/recurring.json

%YAML 1.1
---
```

#### `queue.yml`

Planned

#### `cache.yml`

Planned

#### `cable.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/cable.json

%YAML 1.1
---
```

### Rubocop

#### `rubocop.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rubocop.json

%YAML 1.1
---
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

%YAML 1.1
---
```

### I18n

#### `locales/{language}.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/i18n/locale.json

%YAML 1.1
---
```

## Contributing

If you find an issue with a schema, for example it says that something is invalid when it isn’t, please open an issue with an example.

The schemas are written in JSON Schema version 7 (since that’s the version that YAML LSP supports). They are currently committed directly to the `dist` folder, which is deployed automatically to Cloudflare.

## Why is it called RubySchema?

I know it’s confusing. RubySchema provides JSON Schemas for YAML files. 🤯 The name reflects the purpose of providing schemas specifically for the Ruby community, where a lot of Ruby gems rely on YAML/JSON configuration files. There’s another project called [JSON Schema Store](https://www.schemastore.org) with a significantly wider scope.
