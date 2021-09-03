module ApplicationHelper
  def convert_boolean_to_character(converting_target)
    converting_target ? '○' : '×'
  end
end
