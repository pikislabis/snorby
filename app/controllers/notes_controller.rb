class NotesController < ApplicationController
  before_action :require_administrative_privileges, :set_note, only: [:destroy]
  before_action :set_event, only: [:create, :new]

  def new
  end

  def create
    @note = @event.notes.create(user: @user, body: params[:body])
    if @note.save
      Delayed::Job.enqueue(Snorby::Jobs::NoteNotification.new(@note.id))
    end
  end

  def destroy
    @event = @note.event
    @note.destroy
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def set_event
    @event = Event.find_by(sid: params[:sid], cid: params[:cid])
    @user = User.current_user
  end
end
