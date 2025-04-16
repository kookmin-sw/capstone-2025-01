class CreateAiPromptTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_prompt_templates do |t|
      t.string :name, null: false
      t.text :description
      t.text :template, null: false
      t.timestamps
    end

    add_index :ai_prompt_templates, :name, unique: true
  end
end
