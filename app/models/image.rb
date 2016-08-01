# encoding: UTF-8
class Image < ActiveRecord::Base
  belongs_to :album, inverse_of: :images, counter_cache: true
  belongs_to :photographer, class_name: User
  scope :filename, -> { order(:filename) }
  mount_uploader :file, ImageUploader
  validates :file, :filename, presence: true
  validates :filename, uniqueness: { scope: :album_id, message: '%{value} är redan uppladdad' }

  def original
    file.url
  end

  def thumb
    file.thumb.url
  end

  def view
    file.large.url
  end

  def parent
    album
  end
end
