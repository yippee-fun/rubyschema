# frozen_string_literal: true

updated_files = []
skipped_files = []
failed_files = []

yaml_schemas = {
  "./.rubocop.yml" => "https://www.rubyschema.org/rubocop.json",
  "./.standard.yml" => "https://www.rubyschema.org/standard.json",
  "./shoryuken.yml" => "https://www.rubyschema.org/shoryuken.json",
  "./.honeybadger.yml" => "https://www.rubyschema.org/honeybadger.json",
  "./config/honeybadger.yml" => "https://www.rubyschema.org/honeybadger.json",
  "./config/cable.yml" => "https://www.rubyschema.org/kamal/cable.json",
  "./config/deploy.yml" => "https://www.rubyschema.org/kamal/deploy.json",
  "./config/sidekiq.yml" => "https://www.rubyschema.org/sidekiq.yml",
  "./config/storage.yml" => "https://www.rubyschema.org/rails/storage.json",
  "./config/database.yml" => "https://www.rubyschema.org/rails/database.json",
  "./config/rorvswild.yml" => "https://www.rubyschema.org/rorvswild.json",
  "./config/locales/**/*.yml" => "https://www.rubyschema.org/i18n/locale.json",
  "./config/recurring.yml" => "https://www.rubyschema.org/rails/recurring.json",
  "./.circleci/config.yml" => "https://json.schemastore.org/circleciconfig.json",
  "./.github/workflows/**/*.yml" => "https://json.schemastore.org/github-workflow.json",
  "./app/**/package.yml" => "https://www.rubyschema.org/packwerk/package.yml",
}.freeze

json_schemas = {
  "./.prettierrc" => "https://www.schemastore.org/prettierrc.json",
  "./tsconfig.json" => "https://www.schemastore.org/tsconfig.json",
  "./.stylelintrc" => "https://www.schemastore.org/stylelintrc.json",
  "./config/vite.json" => "https://www.rubyschema.org/vite.json",
}.freeze

yaml_schemas.each do |pattern, schema_url|
  schema_comment = "# yaml-language-server: $schema=#{schema_url}"

  Dir.glob(pattern).each do |file_path|
    source = File.read(file_path).split("\n")

    source.reject! do |line|
      line.start_with? "# yaml-language-server: $schema="
    end

    unless source.include?("%YAML 1.1")
      if (position = source.index("---"))
        source.insert(position, "%YAML 1.1")
      else
        source.unshift("%YAML 1.1", "---")
      end
    end

    source.unshift(schema_comment)

    File.write(file_path, source.join("\n"))
    updated_files << file_path
  rescue => e
    failed_files << { file: file_path, error: e.message }
  end
end

json_schemas.each do |pattern, schema_url|
  Dir.glob(pattern).each do |file_path|
    source = File.read(file_path)
    parsed = JSON.parse(source)

    if parsed.key?("$schema")
      if parsed["$schema"] == schema_url
        skipped_files << file_path
        next
      else
        updated_content = source.gsub(
          /"\$schema":\s*"[^"]*"/,
          "\"$schema\": \"#{schema_url}\""
        )
      end
    else
      if parsed.empty?
        indent = source.match(/^(\s*)\{/)[1]
        schema_line = "\n#{indent}\"$schema\": \"#{schema_url}\""
        updated_content = source.sub(/(\{\s*\n?\s*)(\})/, "\\1#{schema_line}\n\\2")
      else
        indent = source.match(/^(\s*)\{/)[1]
        schema_line = "\n#{indent}\"$schema\": \"#{schema_url}\","
        updated_content = source.sub(/(\{\s*\n)/, "\\1#{schema_line}\n")
      end
    end

    JSON.parse(updated_content)
    File.write(file_path, updated_content)
    updated_files << file_path
  rescue JSON::ParserError => e
    failed_files << { file: file_path, error: "JSON parsing failed: #{e.message}" }
  rescue => e
    failed_files << { file: file_path, error: e.message }
  end
end

say "\n\e[1mAdding Schemas:\e[0m\n\n"

skipped_files.sort.each do |file|
  say "\e[32m~\e[0m #{file}"
end

updated_files.sort.each do |file|
  say "\e[33m+\e[0m #{file}"
end

failed_files.each do |item|
  say "\e[31m✗\e[0m #{item[:file]}"
  say "  \e[31m#{item[:error]}\e[0m"
end

say "\n"
