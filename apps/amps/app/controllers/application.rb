# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
$conf = {}
$conf[:authenticate] = true 
# $conf[:prefix] = "/amps"
$conf[:prefix] = ""

class ApplicationController < ActionController::Base
  include AuthenticatedSystem if $conf[:authenticate]

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_amps_session_id'

  def paginate_collection(collection, options = {})
    default_options = {:per_page => 10, :page => 1}
    options = default_options.merge options
    
    pages = Paginator.new self, collection.size, options[:per_page], options[:page]
    first = pages.current.offset
    last = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    return [pages, slice]
  end

end
