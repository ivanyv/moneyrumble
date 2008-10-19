class Contact < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'owner_id'

  def self.find_or_create_by_name_for_owner(name, owner_id)
    return if name.blank?
    contact = find(:first, :conditions => ['lower(name) = ?', name.strip.downcase])
    return contact if contact
    return Contact.create(:name => name.strip, :owner_id => owner_id)
  end
end