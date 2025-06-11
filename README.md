# Ruby Schema

Ruby schema is a collection of JSON schemas for the YAML configuration in common Ruby gems. This gives you auto-complete and validation for these YAML files in text editors that support the YAML language server.

![Example of auto-complete](https://github.com/user-attachments/assets/c8038624-4df5-4dd7-9fcf-787d5c8a5f71)

Just add the `yaml-language-server` comment to the top of your YAML files.

## Rails

### `database.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/database.json
```

### `storage.yml`

```yml
# yaml-language-server: $schema=https://www.rubyschema.org/rails/storage.json
```
