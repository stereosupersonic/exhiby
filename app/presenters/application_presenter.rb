class ApplicationPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  attr_reader :o

  delegate_missing_to :o

  def initialize(object)
    @o = object
  end

  def self.wrap(collection)
    collection.map { |item| new(item) }
  end
end
