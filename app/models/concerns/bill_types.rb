# frozen_string_literal: true
# typed: true

module BillTypes
  extend T::Sig

  LIST = T.let({
    "B01": "헌법개정",
    "B02": "예산안",
    "B03": "결산",
    "B04": "법률안",
    "B05": "동의안",
    "B06": "승인안",
    "B07": "결의안",
    "B08": "건의안",
    "B09": "규칙안",
    "B10": "선출안",
    "B11": "중요동의",
    "B12": "의원징계",
    "B13": "윤리심사",
    "B14": "의원자격심사",
    "B15": "기타안",
    "B16": "기타"
  }.freeze, T::Hash[Symbol, String])
end
