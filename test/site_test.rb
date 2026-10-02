# frozen_string_literal: true

require "minitest/autorun"
require "pathname"

# The homepage, README and Rails template are maintained by hand, so these
# checks catch a schema that was added in one place but not the others.
class SiteTest < Minitest::Test
  ROOT_DIR = Pathname.new(File.expand_path("..", __dir__))
  DIST_DIR = ROOT_DIR.join("dist")
  SCHEMAS = DIST_DIR.glob("**/*.json").map { |path| path.relative_path_from(DIST_DIR).to_s }.sort.freeze

  def test_homepage_links_every_schema
    html = DIST_DIR.join("index.html").read
    missing = SCHEMAS.reject { |schema| html.include?(%(href="/#{schema}")) }

    assert missing.empty?,
      "dist/index.html doesn't link to:\n#{missing.map { |s| "  - /#{s}" }.join("\n")}"
  end

  def test_homepage_schema_count_is_correct
    html = DIST_DIR.join("index.html").read

    assert_includes html, "#{SCHEMAS.size} schemas.",
      "dist/index.html should say there are #{SCHEMAS.size} schemas"
  end

  def test_readme_links_every_schema
    readme = ROOT_DIR.join("README.md").read
    missing = SCHEMAS.reject { |schema| readme.include?("(./dist/#{schema})") }

    assert missing.empty?,
      "README.md doesn't link to:\n#{missing.map { |s| "  - ./dist/#{s}" }.join("\n")}"
  end

  def test_rails_template_points_at_existing_schemas
    template = DIST_DIR.join("rails.rb").read
    urls = template.scan(%r{https://www\.rubyschema\.org/([\w/.-]+\.json)}).flatten.uniq
    missing = urls - SCHEMAS

    assert missing.empty?,
      "dist/rails.rb points at schemas that don't exist:\n#{missing.map { |s| "  - #{s}" }.join("\n")}"
  end
end
