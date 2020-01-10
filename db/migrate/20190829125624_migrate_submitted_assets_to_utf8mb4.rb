# frozen_string_literal: true

# Autogenerated migration to convert submitted_assets to utf8mb4
class MigrateSubmittedAssetsToUtf8mb4 < ActiveRecord::Migration[5.1]
  include MigrationExtensions::EncodingChanges

  def change
    change_encoding('submitted_assets', from: 'latin1', to: 'utf8mb4')
  end
end