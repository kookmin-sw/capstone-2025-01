# frozen_string_literal: true
# typed: true

require "redcarpet"


module MarkdownHelper
  extend T::Sig

  sig { params(text: String, options: T::Hash[String, T.untyped]).returns(String) }
  def markdown(text, options = {})
    new_options = options.clone

    # https://github.com/vmg/redcarpet?tab=readme-ov-file#darling-i-packed-you-a-couple-renderers-for-lunch
    render_options =
      new_options.reverse_merge(
        filter_html: true,
        no_images: true,
        no_links: true,
        no_styles: true,
        safe_links_only: true,
        with_toc_data: true,
        hard_wrap: true,
        link_attributes: {
          target: "_blank",
          rel: "noopener"
        }
      )

    # https://github.com/vmg/redcarpet?tab=readme-ov-file#and-its-like-really-simple-to-use
    extensions =
      new_options.reverse_merge(
        no_intra_emphasis: false,
        tables: true,
        fenced_code_blocks: true,
        autolink: false,
        disable_indented_code_blocks: true,
        strikethrough: true,
        lax_spacing: true,
        space_after_headers: true,
        superscript: true,
        underline: true,
        highlight: true,
        quote: false,
        footnotes: true,
      )

    renderer = Redcarpet::Render::HTML.new(render_options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    # 렌더링 된 마크다운에 "markdown" 스타일 적용
    content_tag :div,
            markdown.render(text).html_safe,
            class: "markdown"
  end
end
