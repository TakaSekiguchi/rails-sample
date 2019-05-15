class Micropost < ActiveRecord::Base
  has_many :likes, dependent: :destroy
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :picture, presence: true
  validate  :picture_size
  has_many :favorite_users, through: :likes, source: :user

  def self.search(search)
    return Micropost.all unless search
    Micropost.where(['content LIKE ?', "%#{search}%"])
  end

  # マイクロポストをいいねする
  def favorite(user)
    likes.create(user_id: user.id)
  end

  # マイクロポストのいいねを解除する（ネーミングセンスに対するクレームは受け付けません）
  def unfavorite(user)
    likes.find_by(user_id: user.id).destroy
  end

  # 現在のユーザーがいいねしてたらtrueを返す
  def favorite?(user)
    favorite_users.include?(user)
  end

  private

  # アップロードされた画像のサイズをバリデーションする
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end
end