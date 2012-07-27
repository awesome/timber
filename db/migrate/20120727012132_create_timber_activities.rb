class CreateTimberActivities < ActiveRecord::Migration
  def self.up
    create_table :timber_activities do |t|
      t.belongs_to :trackable, :polymorphic => true
      t.belongs_to :owner, :polymorphic => true
      t.string :key
      t.text :parameters

      t.timestamps
    end
  end

  def self.down
    drop_table :timber_activities
  end
end
