class Posting < ApplicationRecord

  belongs_to :author,    class_name: 'User', foreign_key: 'user_id'
  belongs_to :editor,    class_name: 'User', foreign_key: 'editor_id'
  
  def article_with_image
    # uses type checks
    # should be moved to proper models
    # if only Article is te one that should not use this
    # thne we can have a module the can be mixed in other models
    return type if type != 'Article'

    # relying on substring indexes is not relyable/maintainable
    figure_start = body.index('<figure')
    figure_end = body.index('</figure>')
    # Can end up with "_" because figure_start and figure_end might be nil
    return "#{figure_start}_#{figure_end}" if figure_start.nil? || figure_end.nil?

    # Not sure that range + 9 will work
    # also 9 is a "magic number"
    image_tags = body[figure_start...figure_end + 9]
    return 'not include <img' unless image_tags.include?('<img')

    posting_image_params(image_tags)
  end

  private

  def posting_image_params(html)
    tag_parse = -> (image, att) { image.match(/#{att}="(.+?)"/) }
    tag_attributes = {}

    %w[alt src data-image].each do |attribute|
      data = tag_parse.(html, attribute)
      unless data.nil?
        tag_attributes[attribute] = data[1] unless data.size < 2
      end
    end
    # tag_parse
    tag_attributes
  end
end
