

class CreateBillDetails < ActiveRecord::Migration[8.0]
  def change
    # API 필드 이름과 1:1 매칭
    # *_xml 필드는 가공을 거치지 않고 XML 형태로 저장
    create_table :bill_details do |t|
      t.timestamps
      # 의안 위원회심사 정보조회 API
      # http:​​/​/apis​.data​.go​.kr​/9710000​/BillInfoService2​/getBillCommissionExaminationInfo
      t.string :jurisdiction_examination_xml, comment: "소관위 심사정보 XML"
      t.string :jurisdiction_meeting_xml, comment: "소관위 회의정보 XML"
      t.string :proc_examination_xml, comment: "법사위 체계자구심사정보 XML"
      t.string :proc_meeting_xml, comment: "법사위 회의정보 XML"
      t.string :comit_examination_xml, comment: "관련위 심사정보 XML"
      t.string :comit_meeting_xml, comment: "관련위 회의정보 XML"

      # 의안 본회의심의 정보조회 API
      # http:​​/​/apis​.data​.go​.kr​/9710000​/BillInfoService2​/getBillDeliverateInfo
      t.string :plenary_session_examination_xml, comment: "본회의 심의정보 XML"
      t.string :plenary_session_modify_xml, comment: "본회의 수정안 XML"
      t.string :plenary_session_gov_recon_xml, comment: "정부재의안 XML"

      # 의안 정부이송 정보조회 API
      # http:​​/​/apis​.data​.go​.kr​/9710000​/BillInfoService2​/getBillTransferredInfo
      t.datetime :bill_transferred_at, comment: "정부이송일"

      # 의안 공포 정보조회 API
      # http:​​/​/apis​.data​.go​.kr​/9710000​/BillInfoService2​/getBillPromulgationInfo
      t.datetime :bill_promulgated_at, comment: "공포일자"
      t.string :bill_promulgation_number, comment: "공포번호"
      t.string :law_bon_url, comment: "공포법률 URL"
      t.string :law_title, comment: "공포법률명"

      # 의안 부가정보 정보조회 API
      # http:​​/​/apis​.data​.go​.kr​/9710000​/BillInfoService2​/getBillAdditionalInfo
      t.string :comm_memo_xml, comment: "비고 XML"
      t.string :exhaust_xml, comment: "대안반영폐기 의안목록 XML"
      t.string :bill_gbn_cd_xml, comment: "대안 XML"

      # Bill FK
      t.references :bill, null: false, foreign_key: true, index: { name: "index_bill_details_on_bill_id" }
    end
  end
end
