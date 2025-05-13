ActiveAdmin.register BillSummary do
  # Specify parameters which should be permitted for assignment
  permit_params :content, :summary_type, :editor_id, :edit_reason

  # For security, limit the actions that should be available
  actions :all, except: []

  # Add or remove filters to toggle their visibility
  filter :id
  filter :bill
  filter :content
  filter :summary_type
  filter :llm_model
  filter :editor
  filter :edit_reason
  filter :created_at
  filter :updated_at

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    id_column
    column :bill
    column :content do |bill_summary|
      truncate(bill_summary.content, length: 50)
    end
    column :summary_type
    column :llm_model
    column :editor
    column :edit_reason
    column :created_at
    column :updated_at
    actions
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :bill
      row :content
      row :summary_type
      row :llm_model
      row :editor
      row :edit_reason
      row :created_at
      row :updated_at
    end
  end

  # Add or remove fields to toggle their visibility in the form
  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :bill
      f.input :content
      f.input :summary_type
      f.input :llm_model
      f.input :editor
      f.input :edit_reason
    end
    f.actions
  end
end
