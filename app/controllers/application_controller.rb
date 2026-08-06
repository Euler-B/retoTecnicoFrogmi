class ApplicationController < ActionController::API
  private

  def authenticate_admin!
    configured_token = ENV['ADMIN_TOKEN'].presence
    supplied_token = request.headers['X-Admin-Token'].presence

    return render_unauthorized unless configured_token && supplied_token
    return render_unauthorized unless supplied_token.bytesize == configured_token.bytesize

    render_unauthorized unless ActiveSupport::SecurityUtils.secure_compare(supplied_token, configured_token)
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
