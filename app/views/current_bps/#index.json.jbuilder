json.array!(@current_bps) do |current_bp|
  json.extract! current_bp, :date, :ampm, :sysbp, :diabp
  json.url current_bp_url(current_bp, format: :json)
end
