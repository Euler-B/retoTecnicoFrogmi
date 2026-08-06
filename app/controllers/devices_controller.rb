class DevicesController < ApplicationController
  before_action :authenticate_admin!, only: %i[index destroy]

  def index
    no_store
    render json: { data: Device.order(:id).pluck(:fcm_token) }
  end

  def create
    token = device_params[:fcm_token]
    device = Device.find_or_initialize_by(fcm_token: token)
    new_device = device.new_record?
    device.assign_attributes(device_params)

    if device.save
      render_device_json(device, status: new_device ? :created : :ok)
    else
      render json: { errors: device.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    existing_device = Device.find_by!(fcm_token: token)
    render_device_json(existing_device, status: :ok)
  end

  def destroy
    device = Device.find_by(id: params[:id])
    return render json: { error: 'Device not found' }, status: :not_found unless device

    device.destroy!
    head :no_content
  end

  private

  def render_device_json(device, status:)
    render json: { data: { id: device.id, type: 'device' } }, status: status
  end

  def device_params
    params.permit(:fcm_token, :platform)
  end
end
