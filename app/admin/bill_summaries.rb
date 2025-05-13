ActiveAdmin.register BillSummary do
  permit_params :bill_id, :content, :summary_type, :llm_model, :editor_id, :edit_reason

  actions :index, :show, :new, :create, :destroy

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

  controller do
    # new with optional copy_id
    def new
      if params[:copy_id]
        orig = BillSummary.find(params[:copy_id])
        @bill_summary = BillSummary.new(
          bill:           orig.bill,
          content:        orig.content,
          summary_type:   "manual",
          llm_model:      nil,
          editor:         current_user,
          edit_reason:    nil
        )
      else
        @bill_summary = BillSummary.new
      end
    end

    # enforce required fields on create
    def create
      params[:bill_summary].merge!(
        summary_type: "manual",
        llm_model:    nil,
        editor_id:    current_user.id
      )
      super
    end
  end

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
    actions defaults: false do |bs|
      item "View", admin_bill_summary_path(bs)
      item "Copy", new_admin_bill_summary_path(copy_id: bs.id)
      item "Delete", admin_bill_summary_path(bs), method: :delete,
           data: { confirm: "정말로 삭제하시겠습니까?" }
    end
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
      if f.object.new_record?
        if controller.params[:copy_id]
          # 복사 모드: bill 변경 금지, hidden 로 bill_id 전송
          f.input :bill_id, as: :hidden
          f.input :bill, label: "Bill", input_html: { disabled: true }
        else
          # 일반 신규 생성
          f.input :bill, as: :select, collection: Bill.all
        end
      end

      f.input :content
      f.input :edit_reason
    end
    f.actions
  end
end
