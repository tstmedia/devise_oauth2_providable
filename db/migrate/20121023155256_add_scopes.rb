class AddScopes < ActiveRecord::Migration
  def change
    create_table :oauth2_available_scopes do |t|
      t.belongs_to :client
      t.string :scope_name

      t.timestamps
    end

    create_table :oauth2_enabled_scopes do |t|
      t.belongs_to :user, :available_scope

      t.timestamps
    end
  end
end
