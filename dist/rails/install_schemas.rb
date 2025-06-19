# frozen_string_literal: true

updated_files = []
skipped_files = []
failed_files = []

yaml_schemas = {
  "./.rubocop.yml" => "https://www.rubyschema.org/rubocop.json",
  "./config/deploy.yml" => "https://www.rubyschema.org/kamal/deploy.json",
  "./config/storage.yml" => "https://www.rubyschema.org/rails/storage.json",
  "./config/database.yml" => "https://www.rubyschema.org/rails/database.json",
  "./config/recurring.yml" => "https://www.rubyschema.org/rails/recurring.json",
  "./.circleci/config.yml" => "https://json.schemastore.org/circleciconfig.json",
  "./.github/workflows/**/*.yml" => "https://json.schemastore.org/github-workflow.json",
}.freeze

json_schemas = {
  "./.prettierrc" => "https://www.schemastore.org/prettierrc.json",
  "./tsconfig.json" => "https://www.schemastore.org/tsconfig.json",
  "./.stylelintrc" => "https://www.schemastore.org/stylelintrc.json",
  "./config/vite.json" => "https://www.rubyschema.org/vite.json",
}.freeze

yaml_schemas.each do |pattern, schema_url|
  schema_comment = "# yaml-language-server: $schema=#{schema_url}\n"

  Dir.glob(pattern).each do |file_path|
    source = File.read(file_path)

    if source.start_with?(schema_comment)
      skipped_files << file_path
      next
    end

    source.gsub!(/^# yaml-language-server: \$schema=.*\n/, "")
    File.write(file_path, schema_comment + source)
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
