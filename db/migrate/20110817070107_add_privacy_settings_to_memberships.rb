class AddPrivacySettingsToMemberships < ActiveRecord::Migration
  def self.up
     add_column :memberships, :privacy_settings, :text, :default => {}
  end

  def self.down
    remove_column :memberships, :privacy_settings
  end
end
