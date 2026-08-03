class ReportsController < ApplicationController
  before_action :set_sismo

  def create
    report = @sismo.reports.build(report_params)

    if report.save
      render json: { data: serialize_report(report) }, status: :created
    else
      render json: { errors: report.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_sismo
    @sismo = Sismo.find_by(id: params[:sismo_id])
    render json: { error: 'Feature not found' }, status: :not_found unless @sismo
  end

  def report_params
    params.permit(:felt, :intensity)
  end

  def serialize_report(report)
    {
      id: report.id,
      type: 'report',
      attributes: {
        felt: report.felt,
        intensity: report.intensity,
        sismo_id: report.sismo_id,
        created_at: report.created_at
      }
    }
  end
end
