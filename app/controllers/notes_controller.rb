class NotesController < ApplicationController
  before_action :set_note, :can_access, only: [:show, :edit, :update, :destroy, :share_with_user]
  # GET /notes
  # GET /notes.json
  def index
    @notes = current_user.notes
    @shared_notes = current_user.notes_shared_with_me
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
  end

  # GET /notes/new
  def new
    @note = Note.new
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = Note.new(note_params.merge(user: current_user))

    respond_to do |format|
      if @note.save
        format.html { redirect_to notes_url, notice: 'Note was successfully created.' }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1
  # PATCH/PUT /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to notes_url, notice: "Note #{@note.title} was successfully updated." }
        format.json { render :show, status: :ok, location: @note }
      else
        format.html { render :edit }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_url, notice: 'Note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def all_notes
    if current_user.admin_role?
      @all_user = User.pluck(:email, :id)
      if params[:filter_user_id].present?
        @all_notes = Note.where(user_id: params[:filter_user_id])
      else
        @all_notes = Note.all
      end
      @user_selected = params[:filter_user_id]
    else
      redirect_to notes_url, notice: "You are not authorized to access this page"
    end
  end

  def share_with_user
    if params[:email].present?
      user = User.find_by_email params[:email]
      if user && current_user!=user
        SharedNote.where(note: @note, user: user).first_or_create
        @error, @message = false, "Note was successfully shared with #{user.email}."
      else
        @error = true
        @message = current_user==user ? 'Cannot share with yourself' : 'User not found'
      end
      respond_to do |format|
        format.js { render file: '/notes/share_with_user.js', :content_type => 'text/javascript'}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def note_params
      params.require(:note).permit(:title, :description)
    end

    def can_access
      unless current_user.admin_role? || current_user==@note.user || current_user.notes_shared_with_me.include?(@note)
         redirect_to notes_url, notice: "You are not authorized for this operation"
       end 
    end
end
