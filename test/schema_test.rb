# frozen_string_literal: true

require "minitest/autorun"
require "json_schemer"
require "json"
require "yaml"
require "pathname"

DIST_DIR = Pathname.new(File.expand_path("../dist", __dir__))
FIXTURES_DIR = Pathname.new(File.expand_path("fixtures", __dir__))

# Draft-07 ignores unknown keywords, so a typo like "requried" silently drops the rule.
DRAFT_07_KEYWORDS = %w[
  $schema
  $id
  $ref
  $comment
  title
  description
  default
  examples
  readOnly
  writeOnly
  type
  enum
  const
  multipleOf
  maximum
  exclusiveMaximum
  minimum
  exclusiveMinimum
  maxLength
  minLength
  pattern
  format
  contentMediaType
  contentEncoding
  items
  additionalItems
  maxItems
  minItems
  uniqueItems
  contains
  maxProperties
  minProperties
  required
  properties
  patternProperties
  additionalProperties
  dependencies
  propertyNames
  if
  then
  else
  allOf
  anyOf
  oneOf
  not
  definitions
].freeze

# Extensions understood by the YAML language server and VS Code.
EDITOR_KEYWORDS = %w[
  markdownDescription
  markdownEnumDescriptions
  enumDescriptions
  deprecationMessage
  errorMessage
  defaultSnippets
  doNotSuggest
].freeze

KNOWN_KEYWORDS = (DRAFT_07_KEYWORDS + EDITOR_KEYWORDS).freeze

SUBSCHEMA_KEYWORDS = %w[items additionalItems additionalProperties contains propertyNames if then else not].freeze
SUBSCHEMA_LIST_KEYWORDS = %w[items allOf anyOf oneOf].freeze
SUBSCHEMA_MAP_KEYWORDS = %w[properties patternProperties definitions dependencies].freeze

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

    define_method(:"test_#{name.tr('/', '_')}_uses_known_keywords") do
      schema_data = JSON.parse(schema_path.read)
      unknown = []

      each_subschema(schema_data) do |subschema, pointer|
        (subschema.keys - KNOWN_KEYWORDS).each { |key| unknown << "#{pointer}/#{key}" }
      end

      assert unknown.empty?,
        "#{relative} uses unknown keywords at:\n#{unknown.map { |p| "  - #{p}" }.join("\n")}"
    end

    define_method(:"test_#{name.tr('/', '_')}_refs_resolve") do
      schema_data = JSON.parse(schema_path.read)
      schemer = JSONSchemer.schema(schema_data)
      broken = []

      each_subschema(schema_data) do |subschema, pointer|
        ref = subschema["$ref"]
        next unless ref

        begin
          schemer.ref(ref)
        rescue JSONSchemer::InvalidRefPointer, JSONSchemer::UnknownRef
          broken << "#{pointer}/$ref: #{ref}"
        end
      end

      assert broken.empty?,
        "#{relative} has $refs that don't resolve:\n#{broken.map { |p| "  - #{p}" }.join("\n")}"
    end

    define_method(:"test_#{name.tr('/', '_')}_defaults_and_examples_are_valid") do
      schema_data = JSON.parse(schema_path.read)
      schemer = JSONSchemer.schema(schema_data)
      invalid = []

      each_subschema(schema_data) do |subschema, pointer|
        values = []
        values << ["default", subschema["default"]] if subschema.key?("default")
        Array(subschema["examples"]).each_with_index { |example, index| values << ["examples/#{index}", example] }
        next if values.empty?

        subschemer = schemer.ref(pointer)

        values.each do |key, value|
          invalid << "#{pointer}/#{key}: #{value.inspect}" unless subschemer.valid?(value)
        end
      end

      assert invalid.empty?,
        "#{relative} has defaults or examples that don't match their own schema:\n#{invalid.map { |p| "  - #{p}" }.join("\n")}"
    end

    define_method(:"test_#{name.tr('/', '_')}_has_no_unused_definitions") do
      schema_data = JSON.parse(schema_path.read)
      referenced = []

      each_subschema(schema_data) do |subschema, _pointer|
        ref = subschema["$ref"]
        referenced << unescape_pointer_token(ref.split("/")[2]) if ref&.start_with?("#/definitions/")
      end

      unused = schema_data.fetch("definitions", {}).keys - referenced

      assert unused.empty?,
        "#{relative} has unused definitions:\n#{unused.map { |d| "  - #/definitions/#{d}" }.join("\n")}"
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

  # Yields every schema object in the document with its JSON pointer, skipping
  # values that aren't schemas (e.g. `default`, `enum`, `examples`).
  def each_subschema(schema, pointer = "#", &block)
    return unless schema.is_a?(Hash)

    yield schema, pointer

    schema.each do |keyword, value|
      if SUBSCHEMA_LIST_KEYWORDS.include?(keyword) && value.is_a?(Array)
        value.each_with_index { |item, index| each_subschema(item, "#{pointer}/#{keyword}/#{index}", &block) }
      elsif SUBSCHEMA_KEYWORDS.include?(keyword)
        each_subschema(value, "#{pointer}/#{keyword}", &block)
      elsif SUBSCHEMA_MAP_KEYWORDS.include?(keyword) && value.is_a?(Hash)
        value.each { |key, item| each_subschema(item, "#{pointer}/#{keyword}/#{escape_pointer_token(key)}", &block) }
      end
    end
  end

  def escape_pointer_token(token)
    token.gsub("~", "~0").gsub("/", "~1")
  end

  def unescape_pointer_token(token)
    token.gsub("~1", "/").gsub("~0", "~")
  end

  def find_description_keys(obj, path = "")
    paths = []

    case obj
    when Hash
      if obj.key?("description") && !%w[$schema $id properties].include?(path.split("/").last)
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
