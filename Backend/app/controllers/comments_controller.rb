class CommentsController < ApplicationController
  before_action :set_sismo

  def create
    comment = @sismo.comments.build(comment_params)

    if comment.save
      render json: { data: serialize_comment(comment) }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_sismo
    @sismo = Sismo.find_by(id: params[:sismo_id])
    render json: { error: 'Feature not found' }, status: :not_found unless @sismo
  end

  def comment_params
    params.permit(:body)
  end

  def serialize_comment(comment)
    {
      id: comment.id,
      type: 'comment',
      attributes: {
        body: comment.body,
        sismo_id: comment.sismo_id,
        created_at: comment.created_at
      }
    }
  end
end
