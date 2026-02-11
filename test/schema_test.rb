# frozen_string_literal: true

require "minitest/autorun"
require "json_schemer"
require "json"
require "yaml"
require "pathname"

DIST_DIR = Pathname.new(File.expand_path("../dist", __dir__))
FIXTURES_DIR = Pathname.new(File.expand_path("fixtures", __dir__))

class SchemaTest < Minitest::Test
  DIST_DIR.glob("**/*.json").each do |schema_path|
    relative = schema_path.relative_path_from(DIST_DIR)
    name = relative.to_s.delete_suffix(".json")

    define_method(:"test_#{name.tr('/', '_')}_is_valid_json_schema") do
      schema_data = JSON.parse(schema_path.read)

      result = JSONSchemer.draft7.validate(schema_data).to_a
      assert result.empty?, "#{relative} is not a valid JSON Schema draft-07:\n#{result.map { |e| "  - #{e['error']}" }.join("\n")}"
    end

    define_method(:"test_#{name.tr('/', '_')}_has_required_fields") do
      schema_data = JSON.parse(schema_path.read)

      assert_equal "http://json-schema.org/draft-07/schema#", schema_data["$schema"],
        "#{relative} must set $schema to draft-07"

      assert_equal "https://www.rubyschema.org/#{relative}", schema_data["$id"],
        "#{relative} must set $id to https://www.rubyschema.org/#{relative}"
    end

    define_method(:"test_#{name.tr('/', '_')}_uses_markdown_description") do
      schema_data = JSON.parse(schema_path.read)
      paths = find_description_keys(schema_data)

      assert paths.empty?,
        "#{relative} uses 'description' instead of 'markdownDescription' at:\n#{paths.map { |p| "  - #{p}" }.join("\n")}"
    end

    fixtures_dir = FIXTURES_DIR.join(name)
    next unless fixtures_dir.directory?

    fixtures_dir.glob("**/*.{yml,yaml,json}").each do |fixture_path|
      fixture_relative = fixture_path.relative_path_from(FIXTURES_DIR)

      define_method(:"test_#{fixture_relative.to_s.tr('/.', '_')}_is_valid") do
        schema_data = JSON.parse(schema_path.read)
        schemer = JSONSchemer.schema(schema_data)

        fixture_data = case fixture_path.extname
        when ".json"
          JSON.parse(fixture_path.read)
        else
          YAML.safe_load(fixture_path.read, permitted_classes: [Date, Time], aliases: true)
        end

        errors = schemer.validate(fixture_data).to_a
        assert errors.empty?, "#{fixture_relative} failed validation against #{relative}:\n#{errors.map { |e| "  - #{e['error']} at #{e['data_pointer']}" }.join("\n")}"
      end
    end
  end

  private

  def find_description_keys(obj, path = "")
    paths = []

    case obj
    when Hash
      if obj.key?("description") && !%w[$schema $id].include?(path.split("/").last)
        paths << "#{path}/description"
      end

      obj.each do |key, value|
        paths.concat(find_description_keys(value, "#{path}/#{key}"))
      end
    when Array
      obj.each_with_index do |value, index|
        paths.concat(find_description_keys(value, "#{path}/#{index}"))
      end
    end

    paths
  end
end
