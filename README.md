# Ruby Schema

Ruby schema is a collection of schemas for the YAML and JSON configuration in common Ruby gems. This gives you auto-complete and validation for these YAML files in text editors that support the YAML language server.

![Example of auto-complete](https://github.com/user-attachments/assets/c8038624-4df5-4dd7-9fcf-787d5c8a5f71)

Just add the `yaml-language-server` comment to the top of your YAML files.

## Rails

To install all Rails schemas, run:

```
bundle exec rails app:template LOCATION=https://www.rubyschema.org/rails/install_schemas.rb
```

### `database.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/database.json
```

### `storage.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/storage.json
```

### `recurring.yml`

Planned

### `queue.yml`

Planned

### `cache.yml`

Planned

### `cable.yml`

Planned

## Rubocop

### `rubocop.yml`

Currently only supports the Bundler department. Other departments and cops should work but will have limited validation.

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rubocop.json
```

## Vite

### `vite.json`

```json
{
  "$schema": "https://www.rubyschema.org/vite.json"
}
```

## Kamal

### `deploy.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/kamal/deploy.json
```
